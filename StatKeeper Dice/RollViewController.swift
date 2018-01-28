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

    // User settings
    var game:Int  = 0     // 0 - Strat-O-Matic     1 - APBA
    var sport:Int = 0     // 0 - Baseball          1 - Football    2 - Basketball      3 - Hockey
    var dice:Int  = 0     // 0 - Numeric           1 - Image
    var show:Int  = 0     // 0 - Add dice          1 - Show individual values

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
        let split_die = roll_die(20)
        splitLabel.text = String(split_die)
        
        ATap.red_die_1   = 0
        ATap.red_die_2   = 0
        ATap.white_die_1 = 0
        ATap.white_die_2 = 0
        ATap.split_die   = split_die
        ATap.clear       = false
        
        saveTheData()
    }
    
    
    @IBAction func blackButton(_ sender: UIButton)
    {
        let black_die = roll_die(6)
        
        blackLabel.text = convertBlackDie(black_die: black_die)
        
        ATap.red_die_1   = 0
        ATap.red_die_2   = 0
        ATap.white_die_1 = 0
        ATap.white_die_2 = 0
        ATap.black_die   = black_die
        ATap.split_die   = 0
        ATap.clear       = false
        
        saveTheData()
    }

    @IBAction func gameButton(_ sender: UIButton)
    {
        // Roll all the dice
        let white_die_1 = roll_die(6)
        var white_die_2 = roll_die(6)
        var red_die_1   = roll_die(6)       // Make red dice variables because we will zero them for hockey and basketball
        var red_die_2   = roll_die(6)

        // Add the two white and 2 red (just in case)
        let white_value = white_die_1 + white_die_2
        let red_value   = red_die_1 + red_die_2

        // Strat-O-Matic
        if game == 0
        {
            // Baseball or football, and add the red dice...
            if (sport == 0 || sport == 1)
            {
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
        if (defaults.object(forKey: "Dice") != nil)
        {
            dice = defaults.value(forKey: "Dice") as! Int
        }
        if (defaults.object(forKey: "Show") != nil)
        {
            show = defaults.value(forKey: "Show") as! Int
        }
        
    }

    func setupScreen()
    {
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
                
            }
            
            if sport == 3
            {
                sportType = "Hockey"
                whiteDie1Label.isHidden = false
                if (show == 1)                // Do we show two dice?
                {
                    whiteDie2Label.isHidden = false
                }
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
            }

        gameTypeLabel.text = gameType + " : " + sportType
    }
}
