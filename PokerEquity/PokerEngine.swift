//
//  PokerEngine.swift
//  PokerEquity
//
//  Created by Caitlin Owen on 4/10/26.
//

import Foundation

struct PokerEngine {

    // MARK: - Card Encoding
    // card int = rankIndex * 4 + suitIndex  (0–51)

    private static let rankMap: [String: Int] = [
        "2": 0, "3": 1, "4": 2, "5": 3, "6": 4, "7": 5, "8": 6,
        "9": 7, "10": 8, "J": 9, "Q": 10, "K": 11, "A": 12
    ]

    private static let suitMap: [String: Int] = [
        "♣": 0, "♦": 1, "♥": 2, "♠": 3
    ]

    private static func toInt(_ card: Card) -> Int? {
        guard let r = rankMap[card.rank], let s = suitMap[card.suit] else { return nil }
        return r * 4 + s
    }

    private static func rankOf(_ c: Int) -> Int { c / 4 }
    private static func suitOf(_ c: Int) -> Int { c % 4 }

    // MARK: - 5-Card Hand Evaluator
    // Returns an integer where higher = better hand.
    // Encoding: (category << 20) | tiebreaker
    //   category 0–8 matches the hand categories in the reference doc
    //   tiebreaker packs up to 5 rank nibbles (4 bits each) for proper ordering

    private static func evaluate5(_ h: [Int]) -> Int {
        let ranks = h.map { rankOf($0) }.sorted(by: >)
        let suits = h.map { suitOf($0) }

        let isFlush = Set(suits).count == 1

        var isStraight = false
        var strHigh = ranks[0]
        if Set(ranks).count == 5 {
            if ranks[0] - ranks[4] == 4 {
                isStraight = true
            } else if ranks == [12, 3, 2, 1, 0] { // A-2-3-4-5 wheel
                isStraight = true
                strHigh = 3
            }
        }

        var freq = [Int: Int]()
        for r in ranks { freq[r, default: 0] += 1 }

        // Sort by count desc, then rank desc — gives canonical ordering for tiebreakers
        let ordered = freq.sorted {
            $0.value != $1.value ? $0.value > $1.value : $0.key > $1.key
        }.map { $0.key }

        func pack(_ rs: [Int]) -> Int {
            rs.reduce(0) { ($0 << 4) | $1 }
        }

        let cat: Int
        let tb: Int

        if isStraight && isFlush          { cat = 8; tb = strHigh }
        else if freq.values.contains(4)   { cat = 7; tb = pack(ordered) }       // quad, kicker
        else if ordered.count == 2        { cat = 6; tb = pack(ordered) }       // full house: trip, pair
        else if isFlush                   { cat = 5; tb = pack(ranks) }
        else if isStraight                { cat = 4; tb = strHigh }
        else if freq.values.contains(3)   { cat = 3; tb = pack(ordered) }       // trip, k1, k2
        else if ordered.count == 3        { cat = 2; tb = pack(ordered) }       // p1, p2, kicker
        else if freq.values.contains(2)   { cat = 1; tb = pack(ordered) }       // pair, k1, k2, k3
        else                              { cat = 0; tb = pack(ranks) }         // high card

        return (cat << 20) | tb
    }

    // Best 5-card hand from 5, 6, or 7 cards (checks all C(n,5) subsets)
    private static func bestRank(_ cards: [Int]) -> Int {
        let n = cards.count
        guard n >= 5 else { return 0 }
        if n == 5 { return evaluate5(cards) }
        var best = 0
        for i in 0..<n {
            for j in (i+1)..<n {
                for k in (j+1)..<n {
                    for l in (k+1)..<n {
                        for m in (l+1)..<n {
                            let r = evaluate5([cards[i], cards[j], cards[k], cards[l], cards[m]])
                            if r > best { best = r }
                        }
                    }
                }
            }
        }
        return best
    }

    // MARK: - Public API

    // Monte Carlo equity simulation (reference doc section 3).
    // Returns win probability as a percentage 0–100.
    static func calculateEquity(
        playerCards: [Card],
        boardCards: [Card],
        numberOfPlayers: Int
    ) -> Double {
        let holeInts  = playerCards.compactMap { toInt($0) }
        let boardInts = boardCards.compactMap  { toInt($0) }
        guard holeInts.count == 2 else { return 0.0 }

        let known       = Set(holeInts + boardInts)
        let deck        = (0..<52).filter { !known.contains($0) }
        let boardNeeded = 5 - boardInts.count
        let numOpponents = max(1, numberOfPlayers - 1)

        let simulations = 1000
        var wins = 0
        var ties = 0

        for _ in 0..<simulations {
            var shuffled = deck.shuffled()

            let board = boardInts + Array(shuffled[0..<boardNeeded])
            shuffled  = Array(shuffled[boardNeeded...])

            let myRank = bestRank(holeInts + board)

            var bestOpp = 0
            for j in 0..<numOpponents {
                let oppRank = bestRank([shuffled[j * 2], shuffled[j * 2 + 1]] + board)
                if oppRank > bestOpp { bestOpp = oppRank }
            }

            if      myRank > bestOpp { wins += 1 }
            else if myRank == bestOpp { ties += 1 }
        }

        return (Double(wins) + Double(ties) * 0.5) / Double(simulations) * 100.0
    }

    // Hand strength = fraction of all possible opponent 2-card holdings your hand beats.
    // With a full board (flop+), enumerates exactly. Preflop/partial board uses Monte Carlo.
    // Returns a percentage 0–100.
    static func calculateHandStrength(
        playerCards: [Card],
        boardCards: [Card]
    ) -> Double {
        let holeInts  = playerCards.compactMap { toInt($0) }
        let boardInts = boardCards.compactMap  { toInt($0) }
        guard holeInts.count == 2 else { return 0.0 }

        let known     = Set(holeInts + boardInts)
        let remaining = (0..<52).filter { !known.contains($0) }

        // Flop or later: enumerate all C(remaining, 2) opponent hands exactly
        if boardInts.count >= 3 {
            let myRank = bestRank(holeInts + boardInts)
            var wins = 0, ties = 0, total = 0
            for i in 0..<remaining.count {
                for j in (i+1)..<remaining.count {
                    let oppRank = bestRank([remaining[i], remaining[j]] + boardInts)
                    if      myRank > oppRank  { wins += 1 }
                    else if myRank == oppRank { ties += 1 }
                    total += 1
                }
            }
            return total > 0 ? (Double(wins) + Double(ties) * 0.5) / Double(total) * 100.0 : 0.0
        }

        // Preflop or partial board: Monte Carlo vs one random opponent
        let boardNeeded = 5 - boardInts.count
        let simulations = 1000
        var wins = 0, ties = 0

        for _ in 0..<simulations {
            let shuffled   = remaining.shuffled()
            let board      = boardInts + Array(shuffled[0..<boardNeeded])
            let myRank     = bestRank(holeInts + board)
            let oppRank    = bestRank([shuffled[boardNeeded], shuffled[boardNeeded + 1]] + board)
            if      myRank > oppRank  { wins += 1 }
            else if myRank == oppRank { ties += 1 }
        }

        return (Double(wins) + Double(ties) * 0.5) / Double(simulations) * 100.0
    }
}
