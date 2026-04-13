//
//  StatBox.swift
//  PokerEquity
//
//  Created by Caitlin Owen on 4/10/26.
//

import Foundation
import SwiftUI

struct StatBox: View
{
    let title: String
    let value: String

    var body: some View
    {
        VStack(spacing: 8)
        {
            Text(title)
                .font(.headline)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.green.opacity(0.15))
        .cornerRadius(14)
    }
}
