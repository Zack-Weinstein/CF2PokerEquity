//
//  GameView.swift
//  PokerEquity
//
//  Created by Caitlin Owen on 4/10/26.
//

import Foundation
import SwiftUI

struct GameView: View {
    let numberOfPlayers: Int

    @State private var playerCard1Rank: String = ""
    @State private var playerCard1Suit: String = "♠"
    @State private var playerCard2Rank: String = ""
    @State private var playerCard2Suit: String = "♥"

    @State private var boardRanks: [String] = Array(repeating: "", count: 5)
    @State private var boardSuits: [String] = Array(repeating: "♠", count: 5)

    @State private var equity: Double = 0.0
    @State private var handStrength: Double = 0.0

    let ranks = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
    let suits = ["♠", "♥", "♦", "♣"]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HStack {
                    Text("Players: \(numberOfPlayers)")
                        .font(.headline)

                    Spacer()

                    Button("New Game") {
                        resetGame()
                    }
                    .buttonStyle(.bordered)
                }

                HStack(spacing: 24) {
                    StatBox(title: "Your Equity", value: String(format: "%.1f%%", equity))
                    StatBox(title: "Hand Strength", value: String(format: "%.1f%%", handStrength))
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Your Hand")
                        .font(.headline)

                    HStack(spacing: 12) {
                        CardInputView(rank: $playerCard1Rank, suit: $playerCard1Suit, ranks: ranks, suits: suits)
                        CardInputView(rank: $playerCard2Rank, suit: $playerCard2Suit, ranks: ranks, suits: suits)
                    }
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(0..<5, id: \.self) { i in
                            CardInputView(
                                rank: $boardRanks[i],
                                suit: $boardSuits[i],
                                ranks: ranks,
                                suits: suits
                            )
                        }
                    }
                    .padding(.horizontal, 2)
                }

                Button("Calculate Equity") {
                    calculateMockEquity()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Live Equity")
        .navigationBarTitleDisplayMode(.inline)
    }

    func calculateMockEquity() {
        equity = Double.random(in: 15...85)
        handStrength = Double.random(in: 20...95)
    }

    func resetGame() {
        playerCard1Rank = ""
        playerCard2Rank = ""
        playerCard1Suit = "♠"
        playerCard2Suit = "♥"
        boardRanks = Array(repeating: "", count: 5)
        boardSuits = Array(repeating: "♠", count: 5)
        equity = 0.0
        handStrength = 0.0
    }
}
