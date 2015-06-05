//
//  StudentInfoTableViewController.swift
//  OnTheMap
//
//  Created by Kinan Turjman on 5/12/15.
//  Copyright (c) 2015 Kinan Turjman. All rights reserved.
//

import UIKit

/* Table view to show the list of student locations */
class StudentInfoTableViewController: UITableViewController, UITableViewDataSource {
    
    @IBOutlet var table: UITableView! // outlet to the tableview
    
    var refresh = true // flag to allow refreshing of table data
    var information: [OTMStudentLocation] = [OTMStudentLocation]() // array to store student location information
    
    var count = 0 // a counter to keep track of the amount of data that has been downloaded
    
    /* adds the bottom row for loading more data. Just a row that shows an activity icon */
    func addBottomRow()
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("loadMore") as! CustomLoadTableViewCell
    }
    
    override func viewDidLoad() {
        // automatic dimensioning of row heights
        // from: http://stackoverflow.com/questions/26308510/uitableviewautomaticdimension
        table.estimatedRowHeight = 120;
        table.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        
        // disable the distance tab bar item (until all data is loaded)
        dispatch_async(dispatch_get_main_queue()){
            var tabBarC = self.tabBarController as! TabBarVC
            tabBarC.distanceTabEnabled(false)
        }
        
        // refresh the table
        refreshTable()
    }
    
    /* tableview delegate function for getting the number of rows */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // we add one to the count because we have the extra load more cell
        return self.information.count + 1
    }
    
     /* tableview delegate function for loading the cells */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // if the index of the row being added is equal to the information count, then the cell we
        // add next is the load more cell
        if(indexPath.row == self.information.count)
        {
            // deque cell
            let cell1 = tableView.dequeueReusableCellWithIdentifier("loadMore") as! CustomLoadTableViewCell
            
            // activate the activity indicator
            cell1.activityIndicator.startAnimating()
            
            // if the data loaded is not empty...
            if(self.information.count != 0){
                
                // delay for the effect of loading more information when scrolling down
                delay(1.0){
                    // load more data
                    self.addData()
                    // stop animating the activity indicator
                    cell1.activityIndicator.stopAnimating()
                }
            }
            
            return cell1
            
        } else {
            
            // this is the normal cell that displays the student's name and url
            let cell2 = tableView.dequeueReusableCellWithIdentifier("studentCell") as! CustomStudentLocationCell
            
            let datum = self.information[indexPath.row]
        
            // Check if the data is valid, then set the labels
            if datum.isValid(){
                cell2.name?.text = "\(datum.firstName) \(datum.lastName)"
                cell2.url?.text = datum.mediaURL
            }
            return cell2
        }
    }
    
    /* tableview delegate function to handle selection of a row */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // student tapped, we will load the URL
        
        // get the url
        let urlString = information[indexPath.row].mediaURL
        
        // validate url
        NSURL.validateUrl(urlString, completion: { (success, urlString, error) -> Void in
            
            // if valid, browse to the url
            if(success){
                OTMClient.sharedInstance().browseToURL(urlString!)
            } else {
                // not valid, show alert
                OTMClient.sharedInstance().showAlert(self, title: "Error", message: (error as String), actions: ["OK"], completionHandler: nil)
            }
        })
    }
    
    /* function to refresh all table data */
    func refreshTable()
    {
        // remove all loaded data from the data class
        OTMData.sharedInstance().locationsList.removeAll()
        
        // remove all local data
        information.removeAll()
        
        // reload empty table
        tableView.reloadData()
        
        // set the count to 0
        self.count = 0
        
        // add first batch of data
        addData()
    }
    
    /* adds a batch of data to the table */
    func addData(){
        
        // check if we can refresh data or not
        if(self.refresh){
            
            // activate status bar activity indicator
            activityIndicatorEnabled(true)
            
            // disallow refreshing while we are downloading data
            self.refresh = false
            
            // get the Class Utility Queue background thread
            let queue = dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.value), 0)
        
            // perform the task
            dispatch_sync(queue) {
                
                // load data, skipping the amount of data already loaded, given by self.count
                OTMData.sharedInstance().fetchData(self, skip: self.count, completionHandler: { (result) -> Void in
            
                    // check if a result was returned
                    if let locations = result {
                        
                        // if the result is given, but empty, then no more data to load
                        if(locations.count <= 0){
                            
                            // enable the distance tab bar item
                            dispatch_async(dispatch_get_main_queue()){
                                var tabBarC = self.tabBarController as! TabBarVC
                                tabBarC.distanceTabEnabled(true)
                            }
                        }
                        
                        // for each location downloaded
                        for datum in locations {
                            // append to the local information array
                            self.information.append(datum)
                            
                            // increment counter
                            self.count++
                        }
                    }
                
                    // once done, reload the table
                    dispatch_async(dispatch_get_main_queue()){
                        self.table.reloadData()
                    }
                    
                    // disable the status bar indicator and enable refreshing of data
                    activityIndicatorEnabled(false)
                    self.refresh = true
                })
            }
        }
    }
}
