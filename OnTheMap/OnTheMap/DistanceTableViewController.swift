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
        return self.information.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("studentCell") as! UITableViewCell
            
        let datum = self.information[indexPath.row]
            
        // Set the name and image
        if datum.isValid(){
                
            var formatter = NSNumberFormatter()
            formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
            formatter.groupingSeparator = ","
            var formattedDistanceString = formatter.stringFromNumber(datum.distance)
            println(formattedDistanceString)
            cell.textLabel?.text = "\(datum.firstName) \(datum.lastName)"
            cell.detailTextLabel?.text = "\(formattedDistanceString!) km"
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let latitude = information[indexPath.row].latitude
        let longitude = information[indexPath.row].longitude
        
        println("going to: ")
        println(latitude)
        println(longitude)
        println()
        
        let barViewControllers:[AnyObject]! = self.tabBarController?.viewControllers
        let mapVC = barViewControllers[0] as! MapViewController
        
        self.tabBarController?.selectedViewController = mapVC
        
        mapVC.refresh = false
        
        mapVC.zoomToLocation(latitude, long: longitude)
        
    }
    
    func refreshTable()
    {
        self.information.removeAll()
        addData()
    }
    
    func addData(){
        var unsortedData = OTMData.sharedInstance().locationsList
        self.information = unsortedData.sorted({$0.distance > $1.distance})
        table.reloadData()
    }
}