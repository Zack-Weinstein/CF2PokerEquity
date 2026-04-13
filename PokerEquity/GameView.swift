//
//  GameView.swift
//  PokerEquity
//
//  Created by Caitlin Owen on 4/10/26.
//

import SwiftUI

struct GameView: View
{
    //Lets this screen dismiss itself and return to the first page
    @Environment(\.dismiss) var dismiss

    //Current number of players still in the hand
    @State private var numberOfPlayers: Int

    //Original number of players from the setup screen
    //This lets "Next Hand" restore the original count
    let originalNumberOfPlayers: Int

    //Stores the 7 cards total: first 2 are the player's hand, last 5 are the board
    @State private var cards: [Card] = Array(repeating: Card(), count: 7)

    //Tracks which card slot is currently selected
    @State private var selectedCardIndex: Int = 0

    //Stores the chosen rank until the user picks a suit
    @State private var pendingRank: String = ""

    //Displayed output values
    @State private var equity: Double = 0.0
    @State private var handStrength: Double = 0.0

    //Controls whether the "New Game" confirmation popup appears
    @State private var showNewGameAlert: Bool = false

    //Rank choices shown in two rows
    let topRanks = ["2", "3", "4", "5", "6", "7", "8", "9", "10"]
    let bottomRanks = ["J", "Q", "K", "A"]

    //Suit choices
    let suits = ["♠", "♥", "♦", "♣"]

    //Custom initializer so we can store the original player count
    init(numberOfPlayers: Int)
    {
        self.originalNumberOfPlayers = numberOfPlayers
        _numberOfPlayers = State(initialValue: numberOfPlayers)
    }

    var body: some View
    {
        ScrollView
        {
            VStack(spacing: 18)
            {

                //Top row with New Game button on the left and player count / minus button on the right
                HStack
                {
                    Button("New Game")
                    {
                        showNewGameAlert = true
                    }
                    .buttonStyle(.bordered)

                    Spacer()

                    HStack(spacing: 8)
                    {
                        Text("Players: \(numberOfPlayers)")
                            .font(.headline)

                        Button
                        {
                            //Reduce active players, but never go below 2
                            if numberOfPlayers > 2 {
                                numberOfPlayers -= 1
                                recalculateEquity()
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

                //Equity and hand strength display boxes
                HStack(spacing: 12)
                {
                    StatBox(title: "Your Equity", value: String(format: "%.1f%%", equity))
                    StatBox(title: "Hand Strength", value: String(format: "%.1f%%", handStrength))
                }

                //Card selection section
                VStack(alignment: .leading, spacing: 12)
                {
                    Text("Cards")
                        .font(.headline)

                    //Horizontal scroll view so cards do not get cut off on small screens
                    ScrollView(.horizontal, showsIndicators: false)
                    {
                        HStack
                        {
                            Spacer(minLength: 0)

                            //Main row of 7 cards: 2 larger player cards, divider, 5 smaller board cards
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

                            Spacer(minLength: 0)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }

                //Rank buttons
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

                //Suit buttons
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
                                //Assign the chosen suit to the selected card after a rank has already been chosen
                                assignSuit(suit)
                            }
                            label:
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

                //Bottom buttons
                VStack(spacing: 14)
                {
                    Button("Clear Selected")
                    {
                        clearSelectedCard()
                    }
                    .buttonStyle(.bordered)

                    Button("Next Hand")
                    {
                        startNextHand()
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(12)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Live Equity")
        .navigationBarTitleDisplayMode(.inline)

        //Hides the default back button
        .navigationBarBackButtonHidden(true)

        //Popup confirmation when the user taps "New Game"
        .alert("Start a new game?", isPresented: $showNewGameAlert)
        {
            Button("Cancel", role: .cancel) { }

            Button("Start New Game", role: .destructive)
            {
                resetGame()
                dismiss()
            }
        }
        message:
        {
            Text("Your current game progress will be lost.")
        }

        //Recalculate once when the screen first appears
        .onAppear
        {
            recalculateEquity()
        }
    }

    //Creates one card slot view.
    //If the card is filled, it shows the rank and suit in the proper color. If not, it shows a dash.
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

        //Select this card slot when tapped
        .onTapGesture
        {
            selectedCardIndex = index
        }
    }

    //Creates one rank button.
    //When tapped, it stores the selected rank until the user chooses a suit.
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

    //Completes the currently selected card by assigning the chosen suit.
    //This only works if a rank has already been selected.
    //After filling the card, it auto-advances to the next card and recalculates equity.
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

        recalculateEquity()
    }

    //Clears the currently selected card and recalculates equity
    func clearSelectedCard()
    {
        cards[selectedCardIndex] = Card()
        pendingRank = ""
        recalculateEquity()
    }

    //Starts a new hand while staying on the same screen.
    //This clears the cards, resets selection, restores the original player count, and resets the displayed values.
    func startNextHand()
    {
        cards = Array(repeating: Card(), count: 7)
        selectedCardIndex = 0
        pendingRank = ""
        numberOfPlayers = originalNumberOfPlayers
        equity = 0.0
        handStrength = 0.0
    }

    //Fully resets the game state before returning to the setup screen
    func resetGame()
    {
        cards = Array(repeating: Card(), count: 7)
        selectedCardIndex = 0
        pendingRank = ""
        numberOfPlayers = originalNumberOfPlayers
        equity = 0.0
        handStrength = 0.0
    }

    //Recalculates equity and hand strength automatically.
    //Right now this is placeholder logic until the real backend is connected.
    func recalculateEquity()
    {
        let filledCards = cards.filter { $0.isFilled }.count

        if filledCards == 0
        {
            equity = 0.0
            handStrength = 0.0
            return
        }

        //Temporary placeholder values
        equity = Double.random(in: 15...85)
        handStrength = Double.random(in: 20...95)
    }

    //Returns red for hearts/diamonds and black for spades/clubs
    func cardColor(for suit: String) -> Color
    {
        (suit == "♥" || suit == "♦") ? .red : .black
    }
}
