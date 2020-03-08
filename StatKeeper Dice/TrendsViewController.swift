//
//  TrendsViewController.swift
//  StatKeeper Dice
//
//  Created by App Development on 12/17/17.
//  Copyright © 2017 Kerbink Software. All rights reserved.
//

import UIKit
import CoreData
import Charts

class TrendsViewController: UIViewController
{
    @IBOutlet weak var whiteChart: BarChartView!
    @IBOutlet weak var redChart: BarChartView!
    @IBOutlet weak var splitChart: BarChartView!
    @IBOutlet weak var blackChart: BarChartView!
    @IBOutlet weak var filterValue: UISegmentedControl!
    @IBOutlet weak var whiteChartTop: NSLayoutConstraint!
    @IBOutlet weak var redChartTop: NSLayoutConstraint!
    @IBOutlet weak var blackChartTop: NSLayoutConstraint!
    @IBOutlet weak var splitChartTop: NSLayoutConstraint!

    var tapsMaster = [ARoll]()                      // Array of all taps

    // User settings
    var game:Int  = 0     // 0 - Strat-O-Matic     1 - APBA        2 - BallPark        3 - Dynasty League
    var sport:Int = 0     // 0 - Baseball          1 - Football    2 - Basketball      3 - Hockey
    var split:Int = 0     // 0 - Hide Split button 1 - Show Split button

    var red1Array   = [Int](repeating: 0, count: 51)  // Die 1-50
    var red2Array   = [Int](repeating: 0, count: 7 )  // Die 1-6
    var redTArray   = [Int](repeating: 0, count: 13)  // 2 Dice 2-12
    var white1Array = [Int](repeating: 0, count: 7 )  // Die 1-6
    var white2Array = [Int](repeating: 0, count: 7 )  // Die 1-6
    var whiteTArray = [Int](repeating: 0, count: 13)  // 2 Dice 2-12
    var splitArray  = [Int](repeating: 0, count: 21)  // Die 1-20
    var blackArray  = [Int](repeating: 0, count: 7 )  // Die 1-6
    var filterTotal = -1                              // Will be -1 (all), 9, 19, or 29 (because numbering starts at 0)
    
    var tapsCD     = [NSManagedObject]()              // CoreData array of Tap
    var managedContext: NSManagedObjectContext?       // CoreData access

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
        processUserDefaults()
        setupScreen()

        RetrieveTapsCD()
        SeparateTaps()
        
        whiteChartUpdate()
        redChartUpdate()
        splitChartUpdate()
        blackChartUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    
    // MARK: - Segmented Control (All, Today, Week, Month) Functions
    @IBAction func filterSelected(_ sender: UISegmentedControl)
    {
        // -1 - All
        // 9  - Last 10
        // 19 - Last 20
        // 29 - Last 30
        filterTotal = (sender.selectedSegmentIndex * 10) - 1
        
        SeparateTaps()

        whiteChartUpdate()
        redChartUpdate()
        splitChartUpdate()
        blackChartUpdate()
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
        
        // Clear out the arrays
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

// MARK: - Helper Functions
    
    // Split taps into red, white, black, and split
    func SeparateTaps()
    {
        // Clear the arrays
        for i in 0...6
        {
            white1Array[i] = 0
            white2Array[i] = 0
            red2Array[i]   = 0
            blackArray[i]  = 0
        }
        for i in 0...50
        {
            red1Array[i]   = 0
        }
        for i in 0...12
        {
            whiteTArray[i] = 0
            redTArray[i]   = 0
        }
        for i in 0...20
        {
            splitArray[i] = 0
        }
        
        for tap in tapsMaster
        {
            // Red
            if (tap.red_die_1 > 0)
            {
                if (filterTotal == -1 || (filterTotal > 0 && red1Array[0] <= filterTotal))
                {
                    red1Array[tap.red_die_1] += 1
                    red1Array[0] += 1
                }
            }
            if (tap.red_die_2 > 0)
            {
                if (filterTotal == -1 || filterTotal > 0 && red2Array[0] <= filterTotal)
                {
                    red2Array[tap.red_die_2] += 1
                    red2Array[0] += 1
                }
            }
            if (tap.red_die_1 > 0 && tap.red_die_2 > 0)
            {
                if (filterTotal == -1 || filterTotal > 0 && redTArray[0] <= filterTotal)
                {
                    redTArray[tap.red_die_1 + tap.red_die_2] += 1
                    redTArray[0] += 1
                }
            }
            
            // White
            if (tap.white_die_1 > 0)
            {
                if (filterTotal == -1 || filterTotal > 0 && white1Array[0] <= filterTotal)
                {
                    white1Array[tap.white_die_1] += 1
                    white1Array[0] += 1
                }
            }
            if (tap.white_die_2 > 0)
            {
                if (filterTotal == -1 || filterTotal > 0 && white2Array[0] <= filterTotal)
                {
                    white2Array[tap.white_die_2] += 1
                    white2Array[0] += 1
                }
            }
            if (tap.white_die_1 > 0 && tap.white_die_2 > 0)
            {
                if (filterTotal == -1 || filterTotal > 0 && whiteTArray[0] <= filterTotal)
                {
                    whiteTArray[tap.white_die_1 + tap.white_die_2] += 1
                    whiteTArray[0] += 1
                }
            }
            
            // Split
            if (tap.split_die > 0)
            {
                if (filterTotal == -1 || filterTotal > 0 && splitArray[0] <= filterTotal)
                {
                    splitArray[tap.split_die] += 1
                    splitArray[0] += 1
                }
            }
            
            // Black
            if (tap.black_die > 0)
            {
                if (filterTotal == -1 || filterTotal > 0 && blackArray[0] <= filterTotal)
                {
                    blackArray[tap.black_die] += 1
                    blackArray[0] += 1
                }
            }
        }
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
        if (defaults.object(forKey: "Split") != nil)
        {
            split = defaults.value(forKey: "Split") as! Int
        }

    }

    func setupScreen()
    {
        let constraint1:CGFloat = 28.0
        let constraint2:CGFloat = 160.0
        let constraint3:CGFloat = 292.0

        // Turn everything off
        whiteChart.isHidden = true
        redChart.isHidden   = true
        splitChart.isHidden = true
        blackChart.isHidden = true
        
        // Strat-O-Matic
        if (game == 0)
        {
            if sport == 0
            {
                whiteChart.isHidden  = false
                redChart.isHidden    = false
                splitChart.isHidden  = false
                whiteChartTop.constant = constraint1
                redChartTop.constant   = constraint2
                splitChartTop.constant = constraint3
            }
            
            if sport == 1
            {
                whiteChart.isHidden    = false
                redChart.isHidden      = false
                blackChart.isHidden    = false
                whiteChartTop.constant = constraint1
                redChartTop.constant   = constraint2
                blackChartTop.constant = constraint3
            }
            if sport == 2
            {
                whiteChart.isHidden    = false
                blackChart.isHidden    = false
                whiteChartTop.constant = constraint1
                blackChartTop.constant = constraint2

                if (split == 1)
                {
                    splitChart.isHidden    = false
                    splitChartTop.constant = constraint3
                }
                    
            }
            
            if sport == 3
            {
                whiteChart.isHidden    = false
                whiteChartTop.constant = constraint1
            }
        }
        
        // APBA
        if (game == 1)
        {
            whiteChart.isHidden    = false
            redChart.isHidden      = false
            whiteChartTop.constant = constraint1
            redChartTop.constant   = constraint2
        }

        
        // BallPark & Dynasty League
        if (game == 2 && game == 3)
        {
            redChart.isHidden   = false
            redChartTop.constant = constraint1
        }

    }

    
// MARK: - Chart creation Functions

    func whiteChartUpdate ()
    {
        var dataEntries = [ChartDataEntry]()
        var upperLimit = 6
        var lowerLimit = 1
        var label = "White (" + String(white1Array[0]) + ")"
        
        if (game == 0 && sport == 2 || game == 0 && sport == 3)
        {
            label = "White Combined (" + String(whiteTArray[0]) + ")"
            lowerLimit = 2
            upperLimit = 12
        }
        for i in lowerLimit...upperLimit
        {
            var dataEntry: BarChartDataEntry
            
            // Strat-O-Matic basketball and hockey, we add the two white dice
            if (game == 0 && sport == 2 || game == 0 && sport == 3)
            {
                dataEntry = BarChartDataEntry(x: Double(i), y: Double(whiteTArray[i]))
                
            }
            else
            {
                dataEntry = BarChartDataEntry(x: Double(i), y: Double(white1Array[i]))

            }
            dataEntries.append(dataEntry)
        }
        let dataSet = BarChartDataSet(entries: dataEntries, label: label)

        let data        = BarChartData(dataSets: [dataSet])
        whiteChart.data = data
        whiteChart.data?.setDrawValues(false)
        
        whiteChart.chartDescription?.text      = ""
        whiteChart.backgroundColor             = UIColor.black
        whiteChart.doubleTapToZoomEnabled      = false
        whiteChart.highlightPerTapEnabled      = false
        whiteChart.highlightPerDragEnabled     = false
        
        whiteChart.legend.textColor            = UIColor.white
        
        whiteChart.xAxis.labelTextColor        = UIColor.white
        whiteChart.xAxis.gridColor             = UIColor.white
        whiteChart.xAxis.labelPosition         = .bottom
        whiteChart.xAxis.axisLineColor         = UIColor.white

        whiteChart.rightAxis.gridColor         = UIColor.white
        
        whiteChart.leftAxis.axisLineColor        = UIColor.white
        whiteChart.leftAxis.labelTextColor       = UIColor.white
        whiteChart.leftAxis.drawGridLinesEnabled = false
        whiteChart.leftAxis.granularityEnabled   = true           // No fractions on Y axis
        whiteChart.leftAxis.granularity          = 1.0
        whiteChart.leftAxis.axisMinimum          = 0.0            // No values less than 0

        // All other additions to this function go here
        dataSet.colors = [UIColor.white]

        // This must stay at the end of the function
        whiteChart.notifyDataSetChanged()
    }

    func redChartUpdate ()
    {
        var dataEntries = [ChartDataEntry]()
        var upperLimit  = 6
        var lowerLimit  = 1
        var label       = "Red (" + String(red1Array[0]) + ")"

        if (game == 0 && sport == 0 || game == 0 && sport == 1)
        {
            label = "Red Combined (" + String(redTArray[0]) + ")"
            lowerLimit = 2
            upperLimit = 12
        }

        if (game == 2)
        {
            lowerLimit = 1
            upperLimit = 50
        }
        
        for i in lowerLimit...upperLimit
        {
            var dataEntry: BarChartDataEntry
            
            // Strat-O-Matic baseball and football, we add the two white dice
            if (game == 0 && sport == 0 || game == 0 && sport == 1)
            {
                dataEntry = BarChartDataEntry(x: Double(i), y: Double(redTArray[i]))
            }
            else
            {
                dataEntry = BarChartDataEntry(x: Double(i), y: Double(red1Array[i]))
            }
            dataEntries.append(dataEntry)
        }
        
        let dataSet   = BarChartDataSet(entries: dataEntries, label: label)
        let data      = BarChartData(dataSets: [dataSet])
        redChart.data = data
        redChart.data?.setDrawValues(false)
        redChart.backgroundColor             = UIColor.black
        redChart.doubleTapToZoomEnabled      = false
        redChart.highlightPerTapEnabled      = false
        redChart.highlightPerDragEnabled     = false
        redChart.chartDescription?.text      = ""

        redChart.legend.textColor            = UIColor.white
        
        redChart.xAxis.labelTextColor        = UIColor.white
        redChart.xAxis.gridColor             = UIColor.white
        redChart.xAxis.labelPosition         = .bottom
        redChart.xAxis.axisLineColor         = UIColor.white
        
        redChart.rightAxis.gridColor         = UIColor.white
        
        redChart.leftAxis.axisLineColor        = UIColor.white
        redChart.leftAxis.labelTextColor       = UIColor.white
        redChart.leftAxis.drawGridLinesEnabled = false
        redChart.leftAxis.granularityEnabled   = true           // No fractions on Y axis
        redChart.leftAxis.granularity          = 1.0
        redChart.leftAxis.axisMinimum          = 0.0            // No values less than 0

        // All other additions to this function go here
        dataSet.colors = [UIColor.red]
        
        // This must stay at the end of the function
        redChart.notifyDataSetChanged()
    }

    func splitChartUpdate ()
    {
        var dataEntries = [ChartDataEntry]()
        let label = "Split (" + String(splitArray[0]) + ")"

        for i in 1...20
        {
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(splitArray[i]))
            dataEntries.append(dataEntry)
        }
        let dataSet     = BarChartDataSet(entries: dataEntries, label: label)
        let data        = BarChartData(dataSets: [dataSet])
        splitChart.data = data
        splitChart.data?.setDrawValues(false)
        
        splitChart.backgroundColor             = UIColor.black
        splitChart.doubleTapToZoomEnabled      = false
        splitChart.highlightPerTapEnabled      = false
        splitChart.highlightPerDragEnabled     = false
        splitChart.chartDescription?.text      = ""

        splitChart.legend.textColor            = UIColor.white
        
        splitChart.xAxis.labelTextColor        = UIColor.white
        splitChart.xAxis.gridColor             = UIColor.white
        splitChart.xAxis.labelPosition         = .bottom
        splitChart.xAxis.axisLineColor         = UIColor.white
        
        splitChart.rightAxis.gridColor         = UIColor.white
        
        splitChart.leftAxis.axisLineColor        = UIColor.white
        splitChart.leftAxis.labelTextColor       = UIColor.white
        splitChart.leftAxis.drawGridLinesEnabled = false
        splitChart.leftAxis.granularityEnabled   = true           // No fractions on Y axis
        splitChart.leftAxis.granularity          = 1.0
        splitChart.leftAxis.axisMinimum          = 0.0            // No values less than 0

        // All other additions to this function go here
        dataSet.colors = [UIColor.green]
        
        // This must stay at the end of the function
        splitChart.notifyDataSetChanged()
    }

    func blackChartUpdate ()
    {
        var dataEntries = [ChartDataEntry]()
        let label = "Black (" + String(blackArray[0]) + ")"

        for i in 1...6
        {
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(blackArray[i]))
            dataEntries.append(dataEntry)
        }
        let dataSet     = BarChartDataSet(entries: dataEntries, label: label)
        let data        = BarChartData(dataSets: [dataSet])
        blackChart.data = data
        blackChart.data?.setDrawValues(false)
        
        blackChart.backgroundColor             = UIColor.black
        blackChart.doubleTapToZoomEnabled      = false
        blackChart.highlightPerTapEnabled      = false
        blackChart.highlightPerDragEnabled     = false
        blackChart.chartDescription?.text      = ""

        blackChart.legend.textColor            = UIColor.white
        
        blackChart.xAxis.labelTextColor        = UIColor.white
        blackChart.xAxis.gridColor             = UIColor.white
        blackChart.xAxis.labelPosition         = .bottom
        blackChart.xAxis.axisLineColor         = UIColor.white
        
        blackChart.rightAxis.gridColor         = UIColor.white
        
        blackChart.leftAxis.axisLineColor        = UIColor.white
        blackChart.leftAxis.labelTextColor       = UIColor.white
        blackChart.leftAxis.drawGridLinesEnabled = false
        blackChart.leftAxis.granularityEnabled   = true           // No fractions on Y axis
        blackChart.leftAxis.granularity          = 1.0
        blackChart.leftAxis.axisMinimum          = 0.0            // No values less than 0

        // All other additions to this function go here
        dataSet.colors = [UIColor.white]
        
        // This must stay at the end of the function
        blackChart.notifyDataSetChanged()
    }

}
