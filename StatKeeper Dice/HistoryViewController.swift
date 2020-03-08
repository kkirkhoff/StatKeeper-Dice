//
//  SecondViewController.swift
//  StatKeeper Dice
//
//  Created by App Development on 12/16/17.
//  Copyright © 2017 Kerbink Software. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController, UITableViewDataSource
{
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var filterValue: UISegmentedControl!
    
    var tapsMaster  = [ARoll]()                   // Array of all taps
    var tapsTable   = [ARoll]()                   // Sub-array of taps for display in table
    var filterTotal = -1                          // Will be -1 (all), 9, 19, or 29 (because numbering starts at 0)
    var show:Int    = 0                           // 0 - Add dice          1 - Show individual values
    var tapsCD      = [NSManagedObject]()         // CoreData array of Tap
    var managedContext: NSManagedObjectContext?   // CoreData access

    
    // MARK: - Class Functions
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
        
        // Make sure table separators go from edge to edge
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero
        
        tableView.dataSource = self
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }

    override func viewWillAppear(_ animated:Bool)
    {
        processUserDefaults()
        RetrieveTapsCD()
        FillTableArray()
        tableView.reloadData()
    }

// MARK: - CoreData Functions
    
    // Retrieve seasons from CoreData (Seasons)
    func RetrieveTapsCD()
    {
        // We want to fetch ALL seasons. This is where you would filter your fetches
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RollStrat")
        
        // Sort by year/season
        let tapSort = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [tapSort]
        
        // This returns an array of ManagedObjects based on your search criteria
        do {
            let results =
                try managedContext!.fetch(fetchRequest)
            tapsCD = results as! [NSManagedObject]
        } catch let error as NSError {
            print(#function, " Could not fetch \(error), \(error.userInfo)")
        }
        
        // Clear out the array
        tapsMaster.removeAll()
        
        // Transfer CoreData objects to Seasons array
        for item in tapsCD
        {
            let tap = ARoll()
            tap.red_die_1   = item.value(forKey: "red_die_1") as! Int
            tap.red_die_2   = item.value(forKey: "red_die_2") as! Int
            tap.white_die_1 = item.value(forKey: "white_die_1") as! Int
            tap.white_die_2 = item.value(forKey: "white_die_2") as! Int
            tap.split_die   = item.value(forKey: "split_die") as! Int
            tap.black_die   = item.value(forKey: "black_die") as! Int
            tap.clear       = item.value(forKey: "clear") as! Bool
            tap.tap_date    = item.value(forKey: "date") as! Date
            
            // Convert Date into nice day Mar 3, 1934 and time 8:15am
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            tap.tap_day = dateFormatter.string(from: tap.tap_date)
            dateFormatter.dateFormat = "h:mm:ss a"
            dateFormatter.amSymbol = "am"
            dateFormatter.pmSymbol = "pm"
            tap.tap_time = dateFormatter.string(from: tap.tap_date)

            tapsMaster.append(tap)
        }
        
    }
    
    
    
// MARK: - Segmented Control (All, Today, Week, Month) Functions
    @IBAction func filterSelected(_ sender: UISegmentedControl)
    {
        // -1 - All
        // 9  - Last 10
        // 19 - Last 20
        // 29 - Last 30
        filterTotal = (sender.selectedSegmentIndex * 10) - 1
        FillTableArray()
        tableView.reloadData()
    }
    
// MARK: - Helper Functions
    
    func processUserDefaults()
    {
        // Load the settings
        let defaults: UserDefaults = UserDefaults.standard
        
        if (defaults.object(forKey: "Show") != nil)
        {
            show = defaults.value(forKey: "Show") as! Int
        }
        
    }
    func FillTableArray()
    {
        var numberOfTaps = 0
        var leaveLoop    = false
//        let calendar     = NSCalendar.current
//        let monthOfYear  = calendar.component(.month, from: Date())
//        let dayOfYear    = calendar.component(.day, from: Date())
//        let yearOfYear   = calendar.component(.year, from: Date())

        tapsTable.removeAll()
        
        for tap in tapsMaster
        {            
//            let calendarTap = NSCalendar.current
//            let monthOfTap = calendarTap.component(.month, from: tap.tap_date)
//            let dayOfTap = calendarTap.component(.day, from: tap.tap_date)
//            let yearOfTap = calendarTap.component(.year, from: tap.tap_date)

            switch filterTotal
            {
                case -1:     // All
                    tapsTable.append(tap)
                    break
                case 9...29:     // 10, 20, 30
                    if numberOfTaps > filterTotal
                    {
                        leaveLoop = true
                        break
                    }
                    else
                    {
                        tapsTable.append(tap)
                        numberOfTaps += 1
                    }
//                case 3:     // Today
//                    if yearOfTap == yearOfYear && monthOfTap == monthOfYear && dayOfTap == dayOfYear
//                    {
//                        tapsTable.append(tap)
//                    }
                default:
                    print("Invalid filterType: ", filterTotal)
            }
            
            if leaveLoop == true
            {
                break
            }
        }
    }
    
// MARK: - Table Functions
    
    // How many sections does the table have?
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    // How many rows does each section of the table view have?
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return tapsTable.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {

        // We create the cell by using a method of UITableView. We have to hand over the
        // reusable identifier, which we specified in the interface builder. The table
        // view manages the creation and reusing of table view cells.
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier") as! CustomTableViewCell

        // Hide everything, for starters
        cell.splitLabel.isHidden  = true
        cell.clearLabel.isHidden  = true
        cell.white1Label.isHidden = true
        cell.white2Label.isHidden = true
        cell.red1Label.isHidden   = true
        cell.red2Label.isHidden   = true
        cell.blackLabel.isHidden  = true

// Ball Park Baseball
        if tapsTable[indexPath.row].white_die_1 == 0 && tapsTable[indexPath.row].red_die_1 > 0
        {
            // One white and red dice will always be shown. Red values may be combined into one value
            let red                   = String(tapsTable[indexPath.row].red_die_1)
            cell.white1Label.isHidden = true
            cell.red1Label.isHidden   = false
            cell.red1Label.text       = red
        }

// Strat-O-Matic Baseball, Football, and APBA all sports
        if tapsTable[indexPath.row].white_die_1 > 0 && tapsTable[indexPath.row].red_die_1 > 0
        {
            // One white and red dice will always be shown. Red values may be combined into one value
            let white                   = String(tapsTable[indexPath.row].white_die_1)
            cell.white1Label.isHidden   = false
            cell.red1Label.isHidden     = false
            
            if show == 1
            {
                let red1                = String(tapsTable[indexPath.row].red_die_1)
                let red2                = String(tapsTable[indexPath.row].red_die_2)
                cell.red2Label.isHidden = false
                cell.white1Label.text   = white
                cell.red1Label.text     = red1
                cell.red2Label.text     = red2
            }
            else
            {
                let red                 = String(tapsTable[indexPath.row].red_die_1 + tapsTable[indexPath.row].red_die_2)
                cell.white1Label.text   = white
                cell.red1Label.text     = red
            }
        }

// Strat-O-Matic Hockey and Basketball
        // If two white dice were rolled and no black die, it's Strat-O-Matic Hockey
        if tapsTable[indexPath.row].white_die_1 > 0 && tapsTable[indexPath.row].white_die_2 > 0
        {
            let white1  = String(tapsTable[indexPath.row].white_die_1)
            let white2  = String(tapsTable[indexPath.row].white_die_2)
            
            // Display individual dice
            if show == 1
            {
                cell.white1Label.isHidden = false
                cell.white2Label.isHidden = false
                cell.white1Label.text     = white1
                cell.white2Label.text     = white2
            }
            else
            {
                let white_sum  = String(tapsTable[indexPath.row].white_die_1 + tapsTable[indexPath.row].white_die_2)
                cell.white1Label.isHidden = false
                cell.white1Label.text     = white_sum
            }
        }
        
// Strat-O-Matic Baseball (Split roll)
        if tapsTable[indexPath.row].split_die > 0
        {
            let split                = String(tapsTable[indexPath.row].split_die)
            cell.splitLabel.text     = split
            cell.splitLabel.isHidden = false
        }
        
// Strat-O-Matic Football (Black roll)
        if tapsTable[indexPath.row].black_die > 0
        {
            cell.blackLabel.isHidden = false
            cell.blackLabel.text     = convertBlackDie(black_die: tapsTable[indexPath.row].black_die)
        }

// Clear
        if tapsTable[indexPath.row].clear == true
        {
            cell.clearLabel.isHidden  = false
            cell.clearLabel.text      = "Clear"
        }
        
// Date and Time go on every entry
        cell.dayLabel.text   = tapsTable[indexPath.row].tap_day
        cell.timeLabel.text  = tapsTable[indexPath.row].tap_time

        // Make sure table separator goes from edge to edge
        cell.layoutMargins = UIEdgeInsets.zero
        
        return cell
    }
}


