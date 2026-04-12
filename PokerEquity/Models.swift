//
//  Models.swift
//  PokerEquity
//
//  Created by Caitlin Owen on 4/10/26.
//

import Foundation

struct Card: Identifiable, Hashable {
    let id = UUID()
    var rank: String = ""
    var suit: String = ""

    var isFilled: Bool {
        !rank.isEmpty && !suit.isEmpty
    }
}

/*
 struct Card: Hashable {
 let rank: String
 let suit: String
 }
 */
