//
//  SetupView.swift
//  PokerEquity
//
//  Created by Caitlin Owen on 4/10/26.
//

import Foundation
import SwiftUI

struct SetupView: View {
    @State private var numberOfPlayers: Int = 2
    @State private var buyIn: String = ""
    @State private var smallBlind: String = ""
    @State private var bigBlind: String = ""

    var body: some View {
        VStack(spacing: 24) {
            Text("Poker Equity")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 30)

            VStack(alignment: .leading, spacing: 18) {
                Text("Players")
                    .font(.headline)

                Picker("Players", selection: $numberOfPlayers) {
                    ForEach(2...9, id: \.self) { num in
                        Text("\(num)").tag(num)
                    }
                }
                .pickerStyle(.segmented)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Buy In")
                        .font(.headline)
                    TextField("Enter buy in", text: $buyIn)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)

                    HStack(spacing: 16) {
                        VStack(alignment: .leading) {
                            Text("Small Blind")
                                .font(.headline)
                            TextField("SB", text: $smallBlind)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                        }

                        VStack(alignment: .leading) {
                            Text("Big Blind")
                                .font(.headline)
                            TextField("BB", text: $bigBlind)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                        }
                    }
                }
            }
            .padding()
            .background(Color.green.opacity(0.15))
            .cornerRadius(16)

            NavigationLink {
                GameView(numberOfPlayers: numberOfPlayers)
            } label: {
                Text("Start Game")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
            }

            Spacer()
        }
        .padding()
    }
}
