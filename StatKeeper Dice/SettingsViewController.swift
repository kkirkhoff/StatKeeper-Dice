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
    @IBOutlet weak var showSetting: UISegmentedControl!
    @IBOutlet weak var valuesSetting: UISegmentedControl!
    @IBOutlet weak var showLabel: UILabel!
    @IBOutlet weak var sportLabel: UILabel!
    @IBOutlet weak var splitSetting: UISegmentedControl!
    @IBOutlet weak var splitLabel: UILabel!

    var managedContext: NSManagedObjectContext?   // CoreData access

    var game:Int   = 0     // 0 - Strat-O-Matic     1 - APBA        2 - BallPark        3 - Dynasty League
    var sport:Int  = 0     // 0 - Baseball          1 - Football    2 - Basketball      3 - Hockey
    var show:Int   = 0     // 0 - Add dice          1 - Show individual values
    var values:Int = 0     // 0 - Consecutive       1 - Non Consecutive
    // Split setting is only available when using Strat-O-Matic Basketball
    var split:Int  = 0     // 0 - Hide Split button 1 - Show Split button

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

        gameSetting.selectedSegmentIndex   = 0
        sportSetting.selectedSegmentIndex  = 0
        showSetting.selectedSegmentIndex   = 0
        valuesSetting.selectedSegmentIndex = 0
        splitSetting.selectedSegmentIndex  = 0
        
        processUserDefaults()
        
        // Show Split selection if Strat-O-Matic Basketball is selected
        if game == 0 && sport == 2
        {
            showSetting.isEnabled = true
            showLabel.isEnabled   = true
            
            if sport == 2    // Allow Split usage if Strat-O-Matic Basketball
            {
                splitLabel.isEnabled   = true
                splitSetting.isEnabled = true
            }
        }
        else
        {
            splitLabel.isEnabled   = false
            splitSetting.isEnabled = false
        }
    }

    // This will save the initial defaults on the Settings page.
    // We call this in case the person runs the program the first time, doesn't do anything on
    // this page, then goes to another (Data Entry) page.
    override func viewWillDisappear(_ animated:Bool)
    {
        saveUserDefaults()
    }
    
    
// MARK: - Button Functions
    
    @IBAction func DeleteAll(_ sender: UIButton?)
    {
        guard let button = sender else {
            return
        }

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

        if let presenter = alert.popoverPresentationController {
            presenter.sourceView = button
            presenter.sourceRect = button.bounds
        }
        present(alert, animated: true, completion: nil)
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
        
//        if (defaults.object(forKey: "Dice") != nil)
//        {
//            self.diceSetting.selectedSegmentIndex = defaults.value(forKey: "Dice") as! Int
//            dice = defaults.value(forKey: "Dice") as! Int
//
//            if game == 1
//            {
//                showSetting.isEnabled = false
//                showLabel.isEnabled   = false
//            }
//            else
//            {
//                showSetting.isEnabled = true
//                showLabel.isEnabled   = true
//            }
//
//        }
        
        if (defaults.object(forKey: "Show") != nil)
        {
            self.showSetting.selectedSegmentIndex = defaults.value(forKey: "Show") as! Int
            show = defaults.value(forKey: "Show") as! Int
        }
        
        if (defaults.object(forKey: "Values") != nil)
        {
            self.valuesSetting.selectedSegmentIndex = defaults.value(forKey: "Values") as! Int
            values = defaults.value(forKey: "Values") as! Int
        }
        
        if (defaults.object(forKey: "Split") != nil)
        {
            self.splitSetting.selectedSegmentIndex = defaults.value(forKey: "Split") as! Int
            split = defaults.value(forKey: "Split") as! Int
        }
    }
    
    
    func saveUserDefaults()
    {
        let defaults = UserDefaults.standard
        
        defaults.setValue(game,   forKey: "Game")
        defaults.setValue(sport,  forKey: "Sport")
        defaults.setValue(show,   forKey: "Show")
        defaults.setValue(values, forKey: "Values")
        defaults.setValue(split,  forKey: "Split")
    }

    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }

// MARK: - Segmented Control Functions
    @IBAction func gameTapped(_ sender: UISegmentedControl)
    {
        splitLabel.isEnabled   = false
        splitSetting.isEnabled = false
        
        game = sender.selectedSegmentIndex

        if game == 0
        {
            showSetting.isEnabled = true
            showLabel.isEnabled   = true
            
            if sport == 2    // Allow Split usage if Strat-O-Matic Basketball
            {
                splitLabel.isEnabled   = true
                splitSetting.isEnabled = true
            }
        }
        else
        {
            showSetting.isEnabled = false
            showLabel.isEnabled   = false
        }

        sportSetting.isEnabled = true
        sportLabel.isEnabled   = true

        saveUserDefaults()
    }
    
    @IBAction func sportTapped(_ sender: UISegmentedControl)
    {
        splitLabel.isEnabled   = false
        splitSetting.isEnabled = false

        sport = sender.selectedSegmentIndex

        if game == 0 && sport == 2    // Allow Split usage if Strat-O-Matic Basketball
        {
            splitLabel.isEnabled   = true
            splitSetting.isEnabled = true
        }
        saveUserDefaults()
    }

//    @IBAction func diceTapped(_ sender: UISegmentedControl)
//    {
//        dice = sender.selectedSegmentIndex
//
//        saveUserDefaults()
//    }
    
    @IBAction func showTapped(_ sender: UISegmentedControl)
    {
        show = sender.selectedSegmentIndex
        saveUserDefaults()
    }
    
    @IBAction func valuesTapped(_ sender: UISegmentedControl)
    {
        values = sender.selectedSegmentIndex
        saveUserDefaults()
    }
    
    @IBAction func splitTapped(_ sender: UISegmentedControl)
    {
        split = sender.selectedSegmentIndex

        saveUserDefaults()
    }

}
