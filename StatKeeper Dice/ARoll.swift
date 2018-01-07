//
//  ARoll.swift
//  StatKeeper Dice
//
//  Created by App Development on 12/17/17.
//  Copyright © 2017 Kerbink Software. All rights reserved.
//

import UIKit

class ARoll: NSObject
{
    var red_die_1: Int
    var red_die_2: Int
    var white_die_1: Int
    var white_die_2: Int
    var split_die: Int
    var black_die: Int
    var clear: Bool
    var tap_date: Date
    var tap_day: String
    var tap_time: String
    
    override init()
    {
        red_die_1    = 0
        red_die_2    = 0
        white_die_1  = 0
        white_die_2  = 0
        split_die    = 0
        black_die    = 0
        clear        = false
        tap_date     = Date()
        tap_day      = ""
        tap_time     = ""
    }
}
