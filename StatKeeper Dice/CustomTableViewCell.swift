//
//  CustomTableViewCell.swift
//  StatKeeper Dice
//
//  Created by App Development on 12/19/17.
//  Copyright © 2017 Kerbink Software. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell
{
    @IBOutlet weak var white1Label: UILabel!
    @IBOutlet weak var white2Label: UILabel!
    @IBOutlet weak var red1Label: UILabel!
    @IBOutlet weak var red2Label: UILabel!
    @IBOutlet weak var splitLabel: UILabel!
    @IBOutlet weak var clearLabel: UILabel!
    @IBOutlet weak var blackLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() 
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
