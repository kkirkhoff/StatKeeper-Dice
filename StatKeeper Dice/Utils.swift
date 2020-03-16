//
//  Utils.swift
//  StatKeeper Dice
//
//  Created by App Development on 12/25/17.
//  Copyright © 2017 Kerbink Software. All rights reserved.
//

import Foundation

func convertBlackDie(black_die: Int)->String
{
    switch black_die
    {
        case 1...3:
            return "Blank"
        case 4:
            return "X"
        case 5...6:
            return "D"
        default:
            return ""
    }
}

