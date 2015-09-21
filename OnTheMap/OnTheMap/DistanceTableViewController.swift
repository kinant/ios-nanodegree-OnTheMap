//
//  DistanceTableViewController.swift
//  OnTheMap
//
//  Created by KT on 6/4/15.
//  Copyright (c) 2015 Kinan Turjman. All rights reserved.
//

import UIKit

/* This extra table view displays the list of users that have posted locations sorted by how far
 * awawy their posted location is from Udacity HQ. This table view is only selectable when the user
 * has loaded all the data in parse.
 */
class DistanceTableViewController: UITableViewController {
    
    // MARK: Outlets
    @IBOutlet var table: UITableView! // outlet for the tableview
    
    // MARK: Properties
    var information: [OTMStudentLocation] = [OTMStudentLocation]() // local array for storing the student locations
    
    // MARK: Overriden View Functions
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        refreshTable()
    }
    
    // MARK: TableView Delegate Functions
    /* table view delegate function to get the number of rows */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.information.count
    }
    
    /* table view delegate function to render the rows */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // deque cell
        let cell = tableView.dequeueReusableCellWithIdentifier("studentCell")!
        
        // get the information
        let datum = self.information[indexPath.row]
        
        // make sure the information is valid
        if datum.isValid(){
            
            // format the distance of the location to show decimals and commas.
            // from: http://stackoverflow.com/questions/28936474/swift-how-to-format-a-large-number-with-thousands-seperators
            // and: https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSNumberFormatter_Class/
            
            var formatter = NSNumberFormatter()
            formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
            formatter.groupingSeparator = ","
            var formattedDistanceString = formatter.stringFromNumber(datum.distance)

            // set the cell lables
            cell.textLabel?.text = "\(datum.firstName) \(datum.lastName)"
            cell.detailTextLabel?.text = "\(formattedDistanceString!) km"
        }
        
        return cell
    }
    
    /* handle the selection of a row */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // we want to display the placemark of the location selected
        
        // get lat and long
        let latitude = information[indexPath.row].latitude
        let longitude = information[indexPath.row].longitude
        
        // change the selected view of the tab bar to that of the mapview
        let barViewControllers:[AnyObject]! = self.tabBarController?.viewControllers
        let mapVC = barViewControllers[0] as! MapViewController
        self.tabBarController?.selectedViewController = mapVC
        
        // disable refreshing of map view
        mapVC.refresh = false
        
        // zoom to the location selected
        mapVC.zoomToLocation(latitude, long: longitude)
        
    }
    
    // MARK: Table Data Functions
    /* loads the data */
    func addData(){
        
        // load unsorted data stored in data class
        let unsortedData = OTMData.sharedInstance().locationsList
        
        // set the local information array for student's locations (sort by distance)
        self.information = unsortedData.sort({$0.distance > $1.distance})
        
        // reload the table
        table.reloadData()
    }
    
    /* refreshes the table */
    func refreshTable()
    {
        // remove all data
        self.information.removeAll()
        
        // reload all data
        addData()
    }
}