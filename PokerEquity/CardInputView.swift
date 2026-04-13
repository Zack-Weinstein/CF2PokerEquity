//
//  CardInputView.swift
//  PokerEquity
//
//  Created by Caitlin Owen on 4/10/26.
//
import Foundation
import SwiftUI

//This view represents a single card input using dropdown pickers
//(NOTE: our current GameView no longer uses this, but it's still useful to understand and we did the work so why not keep it)
struct CardInputView: View
{

    //These are bindings, meaning this view does NOT own the data.
    //Instead, it reads/writes values from the parent view (like GameView).
    @Binding var rank: String
    @Binding var suit: String

    //Lists of possible ranks and suits passed in from the parent
    let ranks: [String]
    let suits: [String]

    var body: some View
    {

        //Vertical layout for rank picker and suit picker
        VStack(spacing: 8)
        {

            //Rank picker (dropdown menu)
            Picker("Rank", selection: $rank)
            {

                //Default empty option (no rank selected yet)
                Text("-").tag("")

                //Loop through all rank options (2–A)
                ForEach(ranks, id: \.self)
                { rank in
                    Text(rank).tag(rank)
                }
            }
            .pickerStyle(.menu) //makes it a dropdown menu

            //Suit picker (dropdown menu)
            Picker("Suit", selection: $suit)
            {

                //Loop through suit options (♠ ♥ ♦ ♣)
                ForEach(suits, id: \.self)
                { suit in
                    Text(suit).tag(suit)
                }
            }
            .pickerStyle(.menu)
        }

        //Sets the size of the card input box
        .frame(width: 70, height: 90)

        //Adds spacing inside the box
        .padding(8)

        //Light green background to match app styling
        .background(Color.green.opacity(0.12))

        //Adds a green border around the card
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.green, lineWidth: 1)
        )

        //Rounds the corners
        .cornerRadius(10)
    }
}
