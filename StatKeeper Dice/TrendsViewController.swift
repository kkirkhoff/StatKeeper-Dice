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
    @IBOutlet weak var topChart: BarChartView!
    @IBOutlet weak var middleChart: BarChartView!
    @IBOutlet weak var bottomChart: BarChartView!
    @IBOutlet weak var filterValue: UISegmentedControl!
    @IBOutlet weak var topChartConstraint: NSLayoutConstraint!
    @IBOutlet weak var middleChartConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomChartConstraint: NSLayoutConstraint!

    var tapsMaster = [ARoll]()                      // Array of all taps

    // User settings
    var game:Int  = 0     // 0 - Strat-O-Matic     1 - APBA        2 - BallPark        3 - Dynasty League
    var sport:Int = 0     // 0 - Baseball          1 - Football    2 - Basketball      3 - Hockey
    var split:Int = 0     // 0 - Hide Split button 1 - Show Split button

    var red1Array   = [Int](repeating: 0, count: 51)  // Die 1-50
    var red2Array   = [Int](repeating: 0, count: 7 )  // Die 1-6
    var redTArray   = [Int](repeating: 0, count: 13)  // 2 Dice 2-12
    var white1Array = [Int](repeating: 0, count: 10)  // Die 0-9
    var white2Array = [Int](repeating: 0, count: 7 )  // Die 1-6
    var whiteTArray = [Int](repeating: 0, count: 13)  // 2 Dice 2-12
    var splitArray  = [Int](repeating: 0, count: 21)  // Die 1-20
    var blackArray  = [Int](repeating: 0, count: 7 )  // Die 1-6
    var blueArray   = [Int](repeating: 0, count: 10 ) // Die 0-9
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
        blueChartUpdate()
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
        blueChartUpdate()
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
            tap.blue_die    = item.value(forKey: "blue_die") as! Int
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
    
    // Split taps into red, white, blue, black, and split
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
        for i in 0...9
        {
            blueArray[i] = 0
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
            
            // Blue
            if (tap.blue_die > 0)
            {
                if (filterTotal == -1 || filterTotal > 0 && blueArray[0] <= filterTotal)
                {
                    blueArray[tap.blue_die] += 1
                    blueArray[0] += 1
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
        // Turn everything off
        topChart.isHidden    = true
        middleChart.isHidden = true
        bottomChart.isHidden = true
        
        // Strat-O-Matic
        if (game == 0)
        {
            // Baseball - White, Red, Split
            if sport == 0
            {
                topChart.isHidden    = false
                middleChart.isHidden = false
                bottomChart.isHidden = false
            }
            
            // Football - White, Red, Black
            if sport == 1
            {
                topChart.isHidden    = false
                middleChart.isHidden = false
                bottomChart.isHidden = false
            }
            
            // Basketball - White, Black, Split
            if sport == 2
            {
                topChart.isHidden    = false
                middleChart.isHidden    = false

                if (split == 1)
                {
                    bottomChart.isHidden    = false
                }
                    
            }
            
            // Hockey - White
            if sport == 3
            {
                topChart.isHidden    = false
            }
        }
        
        // APBA
        if (game == 1)
        {
            topChart.isHidden    = false
            middleChart.isHidden = false
        }

        
        // BallPark & Dynasty League
        if (game == 2)
        {
            topChart.isHidden    = false
        }
        
        // Dynasty League
        if (game == 3)
        {
            topChart.isHidden    = false
            middleChart.isHidden = false
            bottomChart.isHidden = false
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

        // Dynasty League
        if (game == 3)
        {
            lowerLimit = 0
            upperLimit = 9
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
        let data    = BarChartData(dataSets: [dataSet])
        
        setupChart (topChart, data, dataSet, UIColor.white)
    }

    func redChartUpdate ()
    {
        var dataEntries = [ChartDataEntry]()
        var upperLimit  = 6
        var lowerLimit  = 1
        var label       = "Red (" + String(red1Array[0]) + ")"

        // Strat-O-Matic baseball and football
        if (game == 0 && sport == 0 || game == 0 && sport == 1)
        {
            label = "Red Combined (" + String(redTArray[0]) + ")"
            lowerLimit = 2
            upperLimit = 12
        }
        
        // Ball Park
        if (game == 2)
        {
            lowerLimit = 1
            upperLimit = 50
        }
        
        // Dynasty League
        if (game == 3)
        {
            lowerLimit = 0
            upperLimit = 9
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

        // Ball Park it's the top chart
        if game == 2
        {
            setupChart (topChart, data, dataSet, UIColor.red)
        }
        else
        {
            setupChart (middleChart, data, dataSet, UIColor.red)
        }

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

        // If Strat-O-Matic baseball or basketball and using Split
        if ((game == 0 && sport == 0) || (game == 0 && sport == 2 && split == 1))
        {
            setupChart (bottomChart, data, dataSet, UIColor.green)

            dataSet.colors = [UIColor.green]
        }
    }
    
    func blueChartUpdate ()
    {
        var dataEntries = [ChartDataEntry]()
        let label = "Blue (" + String(splitArray[0]) + ")"

        for i in 0...9
        {
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(blueArray[i]))
            dataEntries.append(dataEntry)
        }
        let dataSet     = BarChartDataSet(entries: dataEntries, label: label)
        let data        = BarChartData(dataSets: [dataSet])

        setupChart (bottomChart, data, dataSet, UIColor.blue)

        dataSet.colors = [UIColor.blue]
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
        
        // Start-O-Matic football
        if game == 0 && sport == 1
        {
            setupChart (bottomChart, data, dataSet, UIColor.white)
        }
        
        // Start-O-Matic basketball
        if game == 0 && sport == 2
        {
            setupChart (middleChart, data, dataSet, UIColor.white)
        }
    }

    func setupChart(_ chart: BarChartView, _ data: BarChartData, _ dataset: BarChartDataSet, _ color: UIColor)
    {
        chart.data = data
        chart.data?.setDrawValues(false)

        chart.backgroundColor               = UIColor.black
        chart.doubleTapToZoomEnabled        = false
        chart.highlightPerTapEnabled        = false
        chart.highlightPerDragEnabled       = false
        chart.chartDescription?.text        = ""

        chart.legend.textColor              = UIColor.white
        
        chart.xAxis.labelTextColor          = UIColor.white
        chart.xAxis.gridColor               = UIColor.white
        chart.xAxis.labelPosition           = .bottom
        chart.xAxis.axisLineColor           = UIColor.white
        
        chart.rightAxis.gridColor           = UIColor.white
        
        chart.leftAxis.axisLineColor        = UIColor.white
        chart.leftAxis.labelTextColor       = UIColor.white
        chart.leftAxis.drawGridLinesEnabled = false
        chart.leftAxis.granularityEnabled   = true           // No fractions on Y axis
        chart.leftAxis.granularity          = 1.0
        chart.leftAxis.axisMinimum          = 0.0            // No values less than 0

        // All other additions to this function go here
        dataset.colors = [color]
        
        // This must stay at the end of the function
        chart.notifyDataSetChanged()

    }
}
