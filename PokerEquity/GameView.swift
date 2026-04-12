//
//  GameView.swift
//  PokerEquity
//
//  Created by Caitlin Owen on 4/10/26.
//

import SwiftUI

struct GameView: View {
    @Environment(\.dismiss) var dismiss

    @State private var numberOfPlayers: Int
    @State private var cards: [Card] = Array(repeating: Card(), count: 7)
    @State private var selectedCardIndex: Int = 0
    @State private var pendingRank: String = ""

    @State private var equity: Double = 0.0
    @State private var handStrength: Double = 0.0
    @State private var showNewGameAlert: Bool = false

    let topRanks = ["2", "3", "4", "5", "6", "7", "8", "9", "10"]
    let bottomRanks = ["J", "Q", "K", "A"]
    let suits = ["♠", "♥", "♦", "♣"]

    init(numberOfPlayers: Int) {
        _numberOfPlayers = State(initialValue: numberOfPlayers)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                HStack {
                    Button("New Game") {
                        showNewGameAlert = true
                    }
                    .buttonStyle(.bordered)

                    Spacer()

                    HStack(spacing: 8) {
                        Text("Players: \(numberOfPlayers)")
                            .font(.headline)

                        Button {
                            if numberOfPlayers > 2 {
                                numberOfPlayers -= 1
                            }
                        } label: {
                            Text("-")
                                .font(.headline)
                                .frame(width: 28, height: 28)
                        }
                        .buttonStyle(.bordered)
                    }
                }

                HStack(spacing: 12) {
                    StatBox(title: "Your Equity", value: String(format: "%.1f%%", equity))
                    StatBox(title: "Hand Strength", value: String(format: "%.1f%%", handStrength))
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Cards")
                        .font(.headline)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .center, spacing: 8) {
                            HStack(spacing: 6) {
                                cardSlot(at: 0, isPlayerCard: true)
                                cardSlot(at: 1, isPlayerCard: true)
                            }
                            .padding(6)
                            .background(Color.green.opacity(0.08))
                            .cornerRadius(10)

                            Rectangle()
                                .fill(Color.gray.opacity(0.4))
                                .frame(width: 1, height: 60)

                            HStack(spacing: 6) {
                                ForEach(2..<7, id: \.self) { index in
                                    cardSlot(at: index, isPlayerCard: false)
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Select Rank")
                        .font(.headline)

                    HStack(spacing: 8) {
                        ForEach(topRanks, id: \.self) { rank in
                            rankButton(rank)
                        }
                    }

                    HStack(spacing: 16) {
                        Spacer()
                        ForEach(bottomRanks, id: \.self) { rank in
                            rankButton(rank)
                        }
                        Spacer()
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Select Suit")
                        .font(.headline)

                    HStack(spacing: 20) {
                        ForEach(suits, id: \.self) { suit in
                            Button {
                                assignSuit(suit)
                            } label: {
                                Text(suit)
                                    .font(.system(size: 32))
                                    .frame(width: 44, height: 44)
                            }
                            .foregroundColor((suit == "♥" || suit == "♦") ? .red : .black)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }

                VStack(spacing: 14) {
                    Button("Clear Selected") {
                        clearSelectedCard()
                    }
                    .buttonStyle(.bordered)

                    Button("Calculate Equity") {
                        calculateMockEquity()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.blue)
                    .cornerRadius(14)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Live Equity")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .alert("Start a new game?", isPresented: $showNewGameAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Start New Game", role: .destructive) {
                resetGame()
                dismiss()
            }
        } message: {
            Text("Your current game progress will be lost.")
        }
    }

    @ViewBuilder
    func cardSlot(at index: Int, isPlayerCard: Bool) -> some View {
        let card = cards[index]

        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)

            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    selectedCardIndex == index ? Color.blue : Color.green,
                    lineWidth: selectedCardIndex == index ? 3 : 1
                )

            if card.isFilled {
                VStack(alignment: .leading, spacing: 2) {
                    Text(card.rank)
                        .font(.system(size: isPlayerCard ? 18 : 14, weight: .bold))
                        .foregroundColor(cardColor(for: card.suit))

                    Text(card.suit)
                        .font(.system(size: isPlayerCard ? 18 : 14))
                        .foregroundColor(cardColor(for: card.suit))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(6)
            } else {
                Text("—")
                    .font(.system(size: isPlayerCard ? 18 : 14, weight: .bold))
                    .foregroundColor(.blue)
            }
        }
        .frame(width: isPlayerCard ? 50 : 38, height: isPlayerCard ? 72 : 58)
        .onTapGesture {
            selectedCardIndex = index
        }
    }

    @ViewBuilder
    func rankButton(_ rank: String) -> some View {
        Button {
            pendingRank = rank
        } label: {
            Text(rank)
                .font(.system(size: 18, weight: .medium))
                .frame(minWidth: 28, minHeight: 36)
                .padding(.horizontal, 4)
                .background(pendingRank == rank ? Color.blue : Color.green.opacity(0.12))
                .foregroundColor(pendingRank == rank ? .white : .primary)
                .cornerRadius(8)
        }
    }

    func assignSuit(_ suit: String) {
        guard !pendingRank.isEmpty else { return }

        cards[selectedCardIndex].rank = pendingRank
        cards[selectedCardIndex].suit = suit
        pendingRank = ""

        if selectedCardIndex < 6 {
            selectedCardIndex += 1
        }
    }

    func clearSelectedCard() {
        cards[selectedCardIndex] = Card()
        pendingRank = ""
    }

    func calculateMockEquity() {
        equity = Double.random(in: 15...85)
        handStrength = Double.random(in: 20...95)
    }

    func resetGame() {
        cards = Array(repeating: Card(), count: 7)
        selectedCardIndex = 0
        pendingRank = ""
        equity = 0.0
        handStrength = 0.0
    }

    func cardColor(for suit: String) -> Color {
        (suit == "♥" || suit == "♦") ? .red : .black
    }
}

/*
 import SwiftUI
 
 struct GameView: View
 {
 @State private var numberOfPlayers: Int
 
 @State private var cards: [Card] = Array(repeating: Card(), count: 7)
 @State private var selectedCardIndex: Int = 0
 @State private var pendingRank: String = ""
 
 @State private var equity: Double = 0.0
 @State private var handStrength: Double = 0.0
 
 let topRanks = ["2", "3", "4", "5", "6", "7", "8", "9", "10"]
 let bottomRanks = ["J", "Q", "K", "A"]
 let suits = ["♠", "♥", "♦", "♣"]
 
 init(numberOfPlayers: Int)
 {
 _numberOfPlayers = State(initialValue: numberOfPlayers)
 }
 
 var body: some View
 {
 ScrollView
 {
 VStack(spacing: 18)
 {
 HStack
 {
 Button("New Game")
 {
 resetGame()
 }
 .buttonStyle(.bordered)
 
 Spacer()
 
 HStack(spacing: 8)
 {
 Text("Players: \(numberOfPlayers)")
 .font(.headline)
 
 Button
 {
 if numberOfPlayers > 2
 {
 numberOfPlayers -= 1
 }
 }
 label:
 {
 Text("-")
 .font(.headline)
 .frame(width: 28, height: 28)
 }
 .buttonStyle(.bordered)
 }
 }
 
 HStack(spacing: 12)
 {
 StatBox(title: "Your Equity", value: String(format: "%.1f%%", equity))
 StatBox(title: "Hand Strength", value: String(format: "%.1f%%", handStrength))
 }
 
 VStack(alignment: .leading, spacing: 12)
 {
 Text("Cards")
 .font(.headline)
 
 ScrollView(.horizontal, showsIndicators: false)
 {
 HStack(alignment: .center, spacing: 8)
 {
 HStack(spacing: 6)
 {
 cardSlot(at: 0, isPlayerCard: true)
 cardSlot(at: 1, isPlayerCard: true)
 }
 .padding(6)
 .background(Color.green.opacity(0.08))
 .cornerRadius(10)
 
 Rectangle()
 .fill(Color.gray.opacity(0.4))
 .frame(width: 1, height: 60)
 
 HStack(spacing: 6)
 {
 ForEach(2..<7, id: \.self)
 { index in
 cardSlot(at: index, isPlayerCard: false)
 }
 }
 }
 .padding(.horizontal, 4)
 }
 }
 
 VStack(alignment: .leading, spacing: 12)
 {
 Text("Select Rank")
 .font(.headline)
 
 HStack(spacing: 8)
 {
 ForEach(topRanks, id: \.self)
 { rank in
 rankButton(rank)
 }
 }
 
 HStack(spacing: 16)
 {
 Spacer()
 ForEach(bottomRanks, id: \.self)
 { rank in
 rankButton(rank)
 }
 Spacer()
 }
 }
 
 VStack(alignment: .leading, spacing: 12)
 {
 Text("Select Suit")
 .font(.headline)
 
 HStack(spacing: 20)
 {
 ForEach(suits, id: \.self)
 { suit in
 Button
 {
 assignSuit(suit)
 } label:
 {
 Text(suit)
 .font(.system(size: 32))
 .frame(width: 44, height: 44)
 }
 .foregroundColor((suit == "♥" || suit == "♦") ? .red : .black)
 }
 }
 .frame(maxWidth: .infinity)
 }
 
 VStack(spacing: 14)
 {
 Button("Clear Selected")
 {
 clearSelectedCard()
 }
 .buttonStyle(.bordered)
 
 Button("Calculate Equity")
 {
 calculateMockEquity()
 }
 .font(.headline)
 .foregroundColor(.white)
 .frame(maxWidth: .infinity)
 .padding(.vertical, 18)
 .background(Color.blue)
 .cornerRadius(14)
 }
 
 Spacer()
 }
 .padding()
 }
 .navigationTitle("Live Equity")
 .navigationBarTitleDisplayMode(.inline)
 }
 
 @ViewBuilder
 func cardSlot(at index: Int, isPlayerCard: Bool) -> some View
 {
 let card = cards[index]
 
 ZStack
 {
 RoundedRectangle(cornerRadius: 10)
 .fill(Color.white)
 
 RoundedRectangle(cornerRadius: 10)
 .stroke(
 selectedCardIndex == index ? Color.blue : Color.green,
 lineWidth: selectedCardIndex == index ? 3 : 1
 )
 
 if card.isFilled
 {
 VStack(alignment: .leading, spacing: 2)
 {
 Text(card.rank)
 .font(.system(size: isPlayerCard ? 18 : 14, weight: .bold))
 .foregroundColor(cardColor(for: card.suit))
 
 Text(card.suit)
 .font(.system(size: isPlayerCard ? 18 : 14))
 .foregroundColor(cardColor(for: card.suit))
 }
 .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
 .padding(6)
 }
 else
 {
 Text("—")
 .font(.system(size: isPlayerCard ? 18 : 14, weight: .bold))
 .foregroundColor(.blue)
 }
 }
 .frame(width: isPlayerCard ? 50 : 38, height: isPlayerCard ? 72 : 58)
 .onTapGesture
 {
 selectedCardIndex = index
 }
 }
 
 @ViewBuilder
 func rankButton(_ rank: String) -> some View
 {
 Button
 {
 pendingRank = rank
 }
 label:
 {
 Text(rank)
 .font(.system(size: 18, weight: .medium))
 .frame(minWidth: 28, minHeight: 36)
 .padding(.horizontal, 4)
 .background(pendingRank == rank ? Color.blue : Color.green.opacity(0.12))
 .foregroundColor(pendingRank == rank ? .white : .primary)
 .cornerRadius(8)
 }
 }
 
 func assignSuit(_ suit: String)
 {
 guard !pendingRank.isEmpty else { return }
 
 cards[selectedCardIndex].rank = pendingRank
 cards[selectedCardIndex].suit = suit
 pendingRank = ""
 
 if selectedCardIndex < 6
 {
 selectedCardIndex += 1
 }
 }
 
 func clearSelectedCard()
 {
 cards[selectedCardIndex] = Card()
 pendingRank = ""
 }
 
 func calculateMockEquity()
 {
 equity = Double.random(in: 15...85)
 handStrength = Double.random(in: 20...95)
 }
 
 func resetGame()
 {
 cards = Array(repeating: Card(), count: 7)
 selectedCardIndex = 0
 pendingRank = ""
 equity = 0.0
 handStrength = 0.0
 }
 
 func cardColor(for suit: String) -> Color
 {
 (suit == "♥" || suit == "♦") ? .red : .black
 }
 }
 */
