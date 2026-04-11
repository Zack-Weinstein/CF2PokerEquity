//
//  CardInputView.swift
//  PokerEquity
//
//  Created by Caitlin Owen on 4/10/26.
//

import Foundation
import SwiftUI

struct CardInputView: View {
    @Binding var rank: String
    @Binding var suit: String

    let ranks: [String]
    let suits: [String]

    var body: some View {
        VStack(spacing: 8) {
            Picker("Rank", selection: $rank) {
                Text("-").tag("")
                ForEach(ranks, id: \.self) { rank in
                    Text(rank).tag(rank)
                }
            }
            .pickerStyle(.menu)

            Picker("Suit", selection: $suit) {
                ForEach(suits, id: \.self) { suit in
                    Text(suit).tag(suit)
                }
            }
            .pickerStyle(.menu)
        }
        .frame(width: 70, height: 90)
        .padding(8)
        .background(Color.green.opacity(0.12))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.green, lineWidth: 1)
        )
        .cornerRadius(10)
    }
}
