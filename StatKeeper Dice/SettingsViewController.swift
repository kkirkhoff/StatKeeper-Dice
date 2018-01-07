//
//  SettingsViewController.swift
//  StatKeeper Dice
//
//  Created by App Development on 12/17/17.
//  Copyright © 2017 Kerbink Software. All rights reserved.
//

import UIKit
import CoreData

class SettingsViewController: UIViewController
{

    @IBOutlet weak var gameSetting: UISegmentedControl!
    @IBOutlet weak var sportSetting: UISegmentedControl!
    @IBOutlet weak var diceSetting: UISegmentedControl!
    @IBOutlet weak var showSetting: UISegmentedControl!
    @IBOutlet weak var showLabel: UILabel!
    
    var managedContext: NSManagedObjectContext?   // CoreData access

    var game:Int  = 0     // 0 - Strat-O-Matic     1 - APBA
    var sport:Int = 0     // 0 - Baseball          1 - Football    2 - Basketball      3 - Hockey
    var dice:Int  = 0     // 0 - Numeric           1 - Image
    var show:Int  = 0     // 0 - Add dice          1 - Show individual values
    
    override func loadView()
    {
        super.loadView()
        
        // Access to CoreData
        managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        
    }

    override func viewWillAppear(_ animated:Bool)
    {

        gameSetting.selectedSegmentIndex  = 0
        sportSetting.selectedSegmentIndex = 0
        diceSetting.selectedSegmentIndex  = 0
        showSetting.selectedSegmentIndex  = 0
        
        processUserDefaults()
    }

    // This will save the initial defaults on the Settings page.
    // We call this in case the person runs the program the first time, doesn't do anything on
    // this page, then goes to another (Data Entry) page.
    override func viewWillDisappear(_ animated:Bool)
    {
        saveUserDefaults()
    }
    
    
// MARK: - Button Functions
    
    @IBAction func DeleteAll(_ sender: UIButton)
    {
        // This will ask if you're sure you want to delete all the taps.
        // If yes, it deletes them and notifies you of the deletion.
        // If no, the alert disappears and nothing has changed.
        let alert = UIAlertController(title: "Delete tap history", message: "This will delete your complete tapping history", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { action in
            self.RemoveAllTapsCD()
            let acknowledge = UIAlertController(title: "All taps have been removed", message: " ", preferredStyle: .alert)
            acknowledge.addAction(UIAlertAction(title: "Ok", style: .cancel))
            self.present(acknowledge, animated: true)
        })
        
        self.present(alert, animated: true)
    }
    
    
// MARK: - Core Data Functions
    
    // Remove taps from CoreData
    func RemoveAllTapsCD()
    {
        // Fetch the Strat rolls.
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RollStrat")
        
        // Create request to delete all records
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try managedContext!.execute(deleteRequest)
        } catch let error as NSError {
            print(#function, " Could not remove Game \(error), \(error.userInfo)")
        }
    }

    
// MARK: - Helper Functions
    
    func processUserDefaults()
    {
        // Load the settings
        let defaults: UserDefaults = UserDefaults.standard
        
        if (defaults.object(forKey: "Game") != nil)
        {
            self.gameSetting.selectedSegmentIndex = defaults.value(forKey: "Game") as! Int
            game = defaults.value(forKey: "Game") as! Int
        }
        if (defaults.object(forKey: "Sport") != nil)
        {
            self.sportSetting.selectedSegmentIndex = defaults.value(forKey: "Sport") as! Int
            sport = defaults.value(forKey: "Sport") as! Int
        }
        if (defaults.object(forKey: "Dice") != nil)
        {
            self.diceSetting.selectedSegmentIndex = defaults.value(forKey: "Dice") as! Int
            dice = defaults.value(forKey: "Dice") as! Int
            
            if game == 1
            {
                showSetting.isEnabled = false
                showLabel.isEnabled   = false
            }
            else
            {
                showSetting.isEnabled = true
                showLabel.isEnabled   = true
            }

        }
        if (defaults.object(forKey: "Show") != nil)
        {
            self.showSetting.selectedSegmentIndex = defaults.value(forKey: "Show") as! Int
            show = defaults.value(forKey: "Show") as! Int
        }
    }
    
    
    func saveUserDefaults()
    {
        let defaults = UserDefaults.standard
        
        defaults.setValue(game,  forKey: "Game")
        defaults.setValue(sport, forKey: "Sport")
        defaults.setValue(dice,  forKey: "Dice")
        defaults.setValue(show,  forKey: "Show")
    }

    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }

// MARK: - Segmented Control Functions
    @IBAction func gameTapped(_ sender: UISegmentedControl)
    {
        game = sender.selectedSegmentIndex
        if game == 1
        {
            showSetting.isEnabled = false
            showLabel.isEnabled   = false
        }
        else
        {
            showSetting.isEnabled = true
            showLabel.isEnabled   = true
        }

        saveUserDefaults()
    }
    
    @IBAction func sportTapped(_ sender: UISegmentedControl)
    {
        sport = sender.selectedSegmentIndex
        saveUserDefaults()
    }

    @IBAction func diceTapped(_ sender: UISegmentedControl)
    {
        dice = sender.selectedSegmentIndex

        saveUserDefaults()
    }
    
    @IBAction func showTapped(_ sender: UISegmentedControl)
    {
        show = sender.selectedSegmentIndex
        saveUserDefaults()
    }
    
}
