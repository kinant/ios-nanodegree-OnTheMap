//
//  StudentInfoTableViewController.swift
//  OnTheMap
//
//  Created by Kinan Turjman on 5/12/15.
//  Copyright (c) 2015 Kinan Turjman. All rights reserved.
//

import UIKit

class StudentInfoTableViewController: UITableViewController, UITableViewDataSource {
    
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
                cell2.textLabel?.text = (datum.firstName + datum.lastName)
                cell2.detailTextLabel?.text = datum.mediaURL
            }
            return cell2
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func refreshTable()
    {
        OTMData.sharedInstance().locationsList.removeAll()
        information.removeAll()
        tableView.reloadData()
        self.count = 0
        addData()
    }
    
    func addData(){
        
        if(self.refresh){
            
            self.refresh = false
            
            let queue = dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.value), 0)
        
            dispatch_sync(queue) {
                OTMData.sharedInstance().fetchData(self, skip: self.count, completionHandler: { (result) -> Void in
            
                    if let locations = result {
                        
                        for datum in locations {
                            self.information.append(datum)
                            self.count++
                        }
                    }
                
                    dispatch_async(dispatch_get_main_queue()){
                        self.table.reloadData()
                    }
                    
                    self.refresh = true
                })
            }
        }
    }
}
