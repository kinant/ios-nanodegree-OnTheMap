//
//  DistanceTableViewController.swift
//  OnTheMap
//
//  Created by KT on 6/4/15.
//  Copyright (c) 2015 Kinan Turjman. All rights reserved.
//

import UIKit

class DistanceTableViewController: UITableViewController, UITableViewDataSource {
    
    @IBOutlet var table: UITableView!
    var refresh = true
    
    var information: [OTMStudentLocation] = [OTMStudentLocation]()
    var count = 0
    
    func addBottomRow()
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("loadMore") as! CustomLoadTableViewCell
        // table.
    }
    
    override func viewDidLoad() {
        table.estimatedRowHeight = 120;
        table.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        
        refreshTable()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.information.count + 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // println("indexPath.row: \(indexPath.row)")
        // println("self.information.count-1: \(self.information.count - 1)")
        
        if(indexPath.row == self.information.count)
        {
            let cell1 = tableView.dequeueReusableCellWithIdentifier("loadMore") as! CustomLoadTableViewCell
            cell1.activityIndicator.startAnimating()
            if(self.information.count != 0){
                delay(2.4){
                    // println("adding data!")
                    self.addData()
                    cell1.activityIndicator.stopAnimating()
                }
            }
            
            return cell1
            
        } else {
            
            let cell2 = tableView.dequeueReusableCellWithIdentifier("studentCell") as! UITableViewCell
            
            let datum = self.information[indexPath.row]
            
            // Set the name and image
            if datum.isValid(){
                
                var formatter = NSNumberFormatter()
                formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
                formatter.groupingSeparator = ","
                var formattedDistanceString = formatter.stringFromNumber(datum.distance)
                println(formattedDistanceString)
                cell2.textLabel?.text = (datum.firstName + datum.lastName)
                cell2.detailTextLabel?.text = "\(formattedDistanceString!) km"
            }
            return cell2
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func refreshTable()
    {
        addData()
    }
    
    func addData(){
        var unsortedData = OTMData.sharedInstance().locationsList
        self.information = unsortedData.sorted({$0.distance > $1.distance})
    }
}