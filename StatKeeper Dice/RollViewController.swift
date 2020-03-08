//
//  FirstViewController.swift
//  StatKeeper Dice
//
//  Created by App Development on 12/16/17.
//  Copyright © 2017 Kerbink Software. All rights reserved.
//

import UIKit
import CoreData

class RollViewController: UIViewController
{

    @IBOutlet weak var whiteDie1Label: UILabel!
    @IBOutlet weak var whiteDie2Label: UILabel!
    @IBOutlet weak var redDie1Label: UILabel!
    @IBOutlet weak var redDie2Label: UILabel!
    @IBOutlet weak var splitLabel: UILabel!
    @IBOutlet weak var blackLabel: UILabel!
    @IBOutlet weak var gameTypeLabel: UILabel!
    @IBOutlet weak var splitButton: UIButton!
    @IBOutlet weak var splitBorder: UIButton!
    @IBOutlet weak var blackButton: UIButton!
    @IBOutlet weak var blackBorder: UIButton!
    @IBOutlet weak var gameBorderTop: NSLayoutConstraint!
    @IBOutlet weak var gameButtonTop: NSLayoutConstraint!
    @IBOutlet weak var redDie1Top: NSLayoutConstraint!
    @IBOutlet weak var redDie2Top: NSLayoutConstraint!
    @IBOutlet weak var whiteDie2Top: NSLayoutConstraint!
    @IBOutlet weak var splitBorderTop: NSLayoutConstraint!
    @IBOutlet weak var splitButtonTop: NSLayoutConstraint!
    @IBOutlet weak var splitDieTop: NSLayoutConstraint!
    @IBOutlet weak var blackBorderTop: NSLayoutConstraint!
    @IBOutlet weak var blackButtonTop: NSLayoutConstraint!
    @IBOutlet weak var blackDieTop: NSLayoutConstraint!
    @IBOutlet weak var clearBorderTop: NSLayoutConstraint!
    @IBOutlet weak var clearButtonTop: NSLayoutConstraint!
    
    // User settings
    var game:Int       = 0   // 0 - Strat-O-Matic     1 - APBA        2 - BallPark        3 - Dynasty League
    var sport:Int      = 0   // 0 - Baseball          1 - Football    2 - Basketball      3 - Hockey
    var show:Int       = 0   // 0 - Add dice          1 - Show individual values
    var values:Int     = 0   // 0 - Consecutive       1 - Not Consecutive
    var split:Int      = 0   // 0 - Hide Split button 1 - Show Split button
    // (Split setting is only available when using Strat-O-Matic Basketball)

    // For use when user doesn't want the same consecutive value
    var prev_red1      = 0
    var prev_red2      = 0
    var prev_white1    = 0
    var prev_white2    = 0
    var prev_black     = 0
    var prev_split     = 0
    var prev_red_value = 0
    
    var ATap = ARoll()
    
    var tapsCD = [NSManagedObject]()                // CoreData array of Tap
    var managedContext: NSManagedObjectContext?     // CoreData access

    
    // MARK: - Class Functions
    override func loadView()
    {
        super.loadView()
        
        // Give me access to CoreData
        managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated:Bool)
    {
        processUserDefaults()
        
        setupScreen()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        // Save the data to the managed context
        do {
            try managedContext!.save()
        } catch let error as NSError  {
            print("Could not save data... \(error), \(error.userInfo)")
        }
    }

    
    // MARK: - CoreData Functions
    
    // Save the tap to CoreData
    func SaveTapCD()
    {
        // Access the Game entity in CoreData
        let entity =  NSEntityDescription.entity(forEntityName: "RollStrat", in:managedContext!)
        
        // Insert a new "record" into the Game entity
        let newTap = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        newTap.setValue(ATap.red_die_1,   forKey: "red_die_1")
        newTap.setValue(ATap.red_die_2,   forKey: "red_die_2")
        newTap.setValue(ATap.white_die_1, forKey: "white_die_1")
        newTap.setValue(ATap.white_die_2, forKey: "white_die_2")
        newTap.setValue(ATap.split_die,   forKey: "split_die")
        newTap.setValue(ATap.black_die,   forKey: "black_die")
        newTap.setValue(ATap.clear,       forKey: "clear")
        newTap.setValue(ATap.tap_date,    forKey: "date")

        tapsCD.append(newTap)
    }
    

    // MARK: - Button Actions
    @IBAction func splitButton(_ sender: UIButton)
    {
        var split_die = prev_split
        
        // If we don't want the same consecutive number...
        if values == 1
        {
            while (split_die == prev_split)
            {
                split_die = roll_die(20  )
            }
        }
        else
        {
            split_die = roll_die(20)
        }
        splitLabel.text = String(split_die)
        
        ATap.red_die_1   = 0
        ATap.red_die_2   = 0
        ATap.white_die_1 = 0
        ATap.white_die_2 = 0
        ATap.black_die   = 0
        ATap.split_die   = split_die
        ATap.clear       = false
        
        prev_split = split_die
        
        saveTheData()
    }
    
    
    @IBAction func blackButton(_ sender: UIButton)
    {
        var black_die = prev_black
        
        // If we don't want the same consecutive number...
        if values == 1
        {
            while (black_die == prev_black)
            {
                black_die = roll_die(6)
            }
        }
        else
        {
            black_die = roll_die(6)
        }

        blackLabel.text = convertBlackDie(black_die: black_die)
        
        ATap.red_die_1   = 0
        ATap.red_die_2   = 0
        ATap.white_die_1 = 0
        ATap.white_die_2 = 0
        ATap.black_die   = black_die
        ATap.split_die   = 0
        ATap.clear       = false
        
        prev_black = black_die
        
        saveTheData()
    }

    @IBAction func gameButton(_ sender: UIButton)
    {
        var white_die_1 = prev_white1
        var white_die_2 = prev_white2
        var red_die_1   = prev_red1
        var red_die_2   = prev_red2
        var red_value   = red_die_1 + red_die_2
        var white_value = white_die_1 + white_die_2

        
        // BallPark
        if game == 2
        {
            if values == 1
            {
                while (red_die_1 == prev_red1)
                {
                    red_die_1 = roll_die(50)
                }
            }
            else
            {
                red_die_1 = roll_die(50)
            }
            
            red_die_2         = 0
            white_die_1       = 0
            white_die_2       = 0
            redDie1Label.text = String(red_die_1)
        }
        
        
        // Strat-O-Matic
        if game == 0
        {
            // Baseball or football, and add the red dice...
            if (sport == 0 || sport == 1)
            {
                if values == 1
                {
                    while (red_value == prev_red_value && white_die_1 == prev_white1)
                    {
                        red_die_1   = roll_die(6)
                        red_die_2   = roll_die(6)
                        white_die_1 = roll_die(6)
                        red_value   = red_die_1 + red_die_2
                    }
                }
                else
                {
                    red_die_1   = roll_die(6)
                    red_die_2   = roll_die(6)
                    white_die_1 = roll_die(6)
                    red_value   = red_die_1 + red_die_2
                }

                white_die_2         = 0
                whiteDie1Label.text = String(white_die_1)
                redDie1Label.text   = String(red_value)
                
                if show == 1
                {
                    redDie1Label.text   = String(red_die_1)
                    redDie2Label.text   = String(red_die_2)
                }
            }
            
            // Basketball or hockey, and show each white die...
            if (sport == 2 || sport == 3)
            {
                if values == 1
                {
                    while (white_die_1 == prev_white1 && white_die_2 == prev_white2)
                    {
                        white_die_1 = roll_die(6)
                        white_die_2 = roll_die(6)
                        white_value = white_die_1 + white_die_2
                    }
                }
                else
                {
                    white_die_1 = roll_die(6)
                    white_die_2 = roll_die(6)
                    white_value = white_die_1 + white_die_2
                }

                // Red dice not used
                red_die_1 = 0
                red_die_2 = 0
                whiteDie1Label.text = String(white_value)

                if show == 1
                {
                    whiteDie1Label.text = String(white_die_1)
                    whiteDie2Label.text = String(white_die_2)
                }
            }
        }
        
        // APBA
        if game == 1
        {
            if values == 1
            {
                while (white_die_1 == prev_white1 && red_die_1 == prev_red1)
                {
                    white_die_1 = roll_die(6)
                    red_die_1   = roll_die(6)
                }
            }
            else
            {
                white_die_1 = roll_die(6)
                red_die_1   = roll_die(6)
            }
            
            white_die_2         = 0
            red_die_2           = 0
            redDie1Label.text   = String(red_die_1)
            whiteDie1Label.text = String(white_die_1)
        }
        
        ATap.red_die_1   = red_die_1
        ATap.red_die_2   = red_die_2
        ATap.white_die_1 = white_die_1
        ATap.white_die_2 = white_die_2
        ATap.split_die   = 0
        ATap.black_die   = 0
        ATap.clear       = false

        prev_red1      = red_die_1
        prev_red2      = red_die_2
        prev_white1    = white_die_1
        prev_white2    = white_die_2
        prev_red_value = red_value
        
        saveTheData()
    }
    
    @IBAction func clearButton(_ sender: UIButton)
    {
        zeroTheNumbers()
        saveTheData()
    }


    // MARK: - Helper Functions
    func roll_die(_ limit:UInt32) -> Int
    {
        return Int(arc4random_uniform(limit) + 1)
    }
    
    func zeroTheNumbers()
    {
        ATap.red_die_1   = 0
        ATap.red_die_2   = 0
        ATap.white_die_1 = 0
        ATap.white_die_2 = 0
        ATap.black_die   = 0
        ATap.split_die   = 0
        ATap.clear       = true

        whiteDie1Label.text = String(ATap.white_die_1)
        whiteDie2Label.text = String(ATap.white_die_2)
        redDie1Label.text   = String(ATap.red_die_1)
        redDie2Label.text   = String(ATap.red_die_2)
        blackLabel.text     = String(ATap.black_die)
        splitLabel.text     = String(ATap.split_die)
        blackLabel.text     = " "

        let my_green = UIColor(red: 59/255, green: 208/255, blue: 108/255, alpha: 1)
        splitLabel.textColor = my_green
        
    }
    
    func saveTheData()
    {
        ATap.tap_date = Date()

        SaveTapCD()
    }
    
    func processUserDefaults()
    {
        // Load the settings
        let defaults: UserDefaults = UserDefaults.standard
        
        if (defaults.object(forKey: "Game") != nil)
        {
            game = defaults.value(forKey: "Game") as! Int
        }
        if (defaults.object(forKey: "Sport") != nil)
        {
            sport = defaults.value(forKey: "Sport") as! Int
        }
        if (defaults.object(forKey: "Values") != nil)
        {
            values = defaults.value(forKey: "Values") as! Int
        }
        if (defaults.object(forKey: "Show") != nil)
        {
            show = defaults.value(forKey: "Show") as! Int
        }        
        if (defaults.object(forKey: "Split") != nil)
        {
            split = defaults.value(forKey: "Split") as! Int
        }

    }

    func setupScreen()
    {
        let constraint1Border:CGFloat = 90.0
        let constraint1Button:CGFloat = 95.0
        let constraint1Data:CGFloat   = 97.0
        let constraint2Border:CGFloat = 200.0
        let constraint2Button:CGFloat = 205.0
        let constraint2Data:CGFloat   = 213.0
        let constraint3Border:CGFloat = 310.0
        let constraint3Button:CGFloat = 315.0
        let constraint3Data:CGFloat   = 323.0
        let constraint4Border:CGFloat = 420.0
        let constraint4Button:CGFloat = 425.0

        var gameType = ""
        var sportType = ""
        
        // Turn everything off
        splitLabel.isHidden     = true
        blackLabel.isHidden     = true
        splitButton.isHidden    = true
        splitBorder.isHidden    = true
        blackButton.isHidden    = true
        blackBorder.isHidden    = true
        whiteDie1Label.isHidden = true
        whiteDie2Label.isHidden = true
        redDie1Label.isHidden   = true
        redDie2Label.isHidden   = true
        splitButton.isEnabled   = false

// Strat-O-Matic
        if (game == 0)
        {
            gameType = "Strat-O-Matic"

            if sport == 0
            {
                sportType               = "Baseball"
                splitLabel.isHidden     = false
                splitButton.isHidden    = false
                splitBorder.isHidden    = false
                splitButton.isEnabled   = true
                whiteDie1Label.isHidden = false
                redDie1Label.isHidden   = false
                if (show == 1)                // Do we show two dice?
                {
                    redDie2Label.isHidden = false
                }
                
                // Set constraints for R, G, C
                gameBorderTop.constant  = constraint1Border
                gameButtonTop.constant  = constraint1Button
                redDie1Top.constant     = constraint1Data
                redDie2Top.constant     = constraint1Data
                whiteDie2Top.constant   = constraint1Data
                splitBorderTop.constant = constraint2Border
                splitButtonTop.constant = constraint2Button
                splitDieTop.constant    = constraint2Data
                clearBorderTop.constant = constraint3Border
                clearButtonTop.constant = constraint3Button
            }
            
            if sport == 1
            {
                sportType               = "Football"
                blackLabel.isHidden     = false
                blackButton.isHidden    = false
                blackBorder.isHidden    = false
                whiteDie1Label.isHidden = false
                redDie1Label.isHidden   = false
                if (show == 1)                // Do we show two dice?
                {
                    redDie2Label.isHidden = false
                }
                
                // Set constraints for R, B, C
                gameBorderTop.constant  = constraint1Border
                gameButtonTop.constant  = constraint1Button
                redDie1Top.constant     = constraint1Data
                redDie2Top.constant     = constraint1Data
                blackBorderTop.constant = constraint2Border
                blackButtonTop.constant = constraint2Button
                blackDieTop.constant    = constraint2Data
                clearBorderTop.constant = constraint3Border
                clearButtonTop.constant = constraint3Button
            }
            if sport == 2
            {
                sportType = "Basketball"
                whiteDie1Label.isHidden = false
                blackLabel.isHidden     = false
                blackLabel.isHidden     = false
                blackButton.isHidden    = false
                blackBorder.isHidden    = false
                
                if (show == 1)                // Do we show two dice?
                {
                    whiteDie2Label.isHidden = false
                }
                
                // Set constraints for R, B, C or R, B, G, C (if Split setting is on)
                gameBorderTop.constant  = constraint1Border
                gameButtonTop.constant  = constraint1Button
                redDie1Top.constant     = constraint1Data
                redDie2Top.constant     = constraint1Data
                blackBorderTop.constant = constraint2Border
                blackButtonTop.constant = constraint2Button
                blackDieTop.constant    = constraint2Data

                // If we did NOT choose (in the Settings) to use a Split die...
                if split == 0
                {
                    clearBorderTop.constant = constraint3Border
                    clearButtonTop.constant = constraint3Button
                }

                // If we DID choose (in the Settings) to use a Split die...
                if split == 1
                {
                    splitLabel.isHidden     = false
                    splitButton.isHidden    = false
                    splitBorder.isHidden    = false
                    splitButton.isEnabled   = true
                    splitBorderTop.constant = constraint3Border
                    splitButtonTop.constant = constraint3Button
                    splitDieTop.constant    = constraint3Data
                    clearBorderTop.constant = constraint4Border
                    clearButtonTop.constant = constraint4Button
                }
            }
            
            if sport == 3
            {
                sportType = "Hockey"
                whiteDie1Label.isHidden = false
                if (show == 1)                // Do we show two dice?
                {
                    whiteDie2Label.isHidden = false
                }
                
                // Set constraints for R, C
                gameBorderTop.constant  = constraint1Border
                gameButtonTop.constant  = constraint1Button
                redDie1Top.constant     = constraint1Data
                redDie2Top.constant     = constraint1Data
                clearBorderTop.constant = constraint2Border
                clearButtonTop.constant = constraint2Button

            }
        }

        // APBA
        if (game == 1)
        {
            gameType = "APBA"
            
            if sport == 0
            {
                sportType = "Baseball"
            }
            if sport == 1
            {
                sportType = "Football"
            }
            if sport == 2
            {
                sportType = "Basketball"
            }
            if sport == 3
            {
                sportType = "Hockey"
            }
            
            whiteDie1Label.isHidden = false
            redDie1Label.isHidden   = false
            
            // Set constraints for R, C
            gameBorderTop.constant  = constraint1Border
            gameButtonTop.constant  = constraint1Button
            redDie1Top.constant     = constraint1Data
            redDie2Top.constant     = constraint1Data
            clearBorderTop.constant = constraint2Border
            clearButtonTop.constant = constraint2Button
        }

        // BallPark
        if (game == 2)
        {
            gameType = "BallPark"
            
            if sport == 0
            {
                sportType = "Baseball"
            }
            if sport == 1
            {
                sportType = "Football"
            }
            if sport == 2
            {
                sportType = "Basketball"
            }
            if sport == 3
            {
                sportType = "Hockey"
            }
            
            whiteDie1Label.isHidden = true
            redDie1Label.isHidden   = false
            
            // Set constraints for R, C
            gameBorderTop.constant  = constraint1Border
            gameButtonTop.constant  = constraint1Button
            redDie1Top.constant     = constraint1Data
            redDie2Top.constant     = constraint1Data
            clearBorderTop.constant = constraint2Border
            clearButtonTop.constant = constraint2Button

        }

        // Dynasty League
        if (game == 3)
        {
            gameType = "Dynasty League"
            
            if sport == 0
            {
                sportType = "Baseball"
            }
            if sport == 1
            {
                sportType = "Football"
            }
            if sport == 2
            {
                sportType = "Basketball"
            }
            if sport == 3
            {
                sportType = "Hockey"
            }
            
            whiteDie1Label.isHidden = true
            redDie1Label.isHidden   = false
            
            // Set constraints for R, C
            gameBorderTop.constant  = constraint1Border
            gameButtonTop.constant  = constraint1Button
            redDie1Top.constant     = constraint1Data
            redDie2Top.constant     = constraint1Data
            clearBorderTop.constant = constraint2Border
            clearButtonTop.constant = constraint2Button

        }

        gameTypeLabel.text = gameType + " : " + sportType
    }
}
