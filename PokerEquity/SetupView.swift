//
//  SetupView.swift
//  PokerEquity
//
//  Created by Caitlin Owen on 4/10/26.
//

import Foundation
import SwiftUI

//This is the first screen of the app where the user sets up the game
struct SetupView: View
{

    //Stores the number of players (default is 2)
    @State private var numberOfPlayers: Int = 2

    //Stores user input for buy-in amount
    @State private var buyIn: String = ""

    //Stores user input for small blind
    @State private var smallBlind: String = ""

    //Stores user input for big blind
    @State private var bigBlind: String = ""

    var body: some View
    {
        VStack(spacing: 24)
        {

            //App title at the top
            Text("Poker Equity")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 30)

            //Main input container (green background box)
            VStack(alignment: .leading, spacing: 18)
            {

                //Section label for number of players
                Text("Players")
                    .font(.headline)

                //Segmented control to choose number of players (2–9)
                Picker("Players", selection: $numberOfPlayers)
                {
                    ForEach(2...9, id: \.self)
                    { num in
                        Text("\(num)").tag(num)
                    }
                }
                .pickerStyle(.segmented)

                //Section for buy-in and blinds
                VStack(alignment: .leading, spacing: 12)
                {

                    //Buy-in label
                    Text("Buy In")
                        .font(.headline)

                    //Text field for entering buy-in amount
                    TextField("Enter buy in", text: $buyIn)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad) //shows numeric keyboard

                    //Row containing small blind and big blind inputs
                    HStack(spacing: 16)
                    {

                        //Small blind input
                        VStack(alignment: .leading)
                        {
                            Text("Small Blind")
                                .font(.headline)

                            TextField("SB", text: $smallBlind)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                        }

                        //Big blind input
                        VStack(alignment: .leading)
                        {
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
            .background(Color.green.opacity(0.15)) //light green background
            .cornerRadius(16)

            //Button that navigates to GameView
            //Passes the selected number of players into the game screen
            NavigationLink
            {
                GameView(numberOfPlayers: numberOfPlayers)
            }
            label:
            {
                Text("Start Game")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
            }

            Spacer() //pushes everything up
        }
        .padding()
    }
}
