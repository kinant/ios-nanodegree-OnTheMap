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
    
    override func viewDidLoad() {
        // table.estimatedRowHeight = 120;
        // table.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        addData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.information.count + 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell
        
        println("indexPath.row: \(indexPath.row)")
        println("self.information.count-1: \(self.information.count - 1)")
        
        if(indexPath.row == self.information.count)
        {
            cell = tableView.dequeueReusableCellWithIdentifier("loadMore") as! UITableViewCell
            
            if(self.information.count != 0){
                delay(2.4){
                    println("adding data!")
                    self.addData()
                }
            }
            
        } else {
        
            cell = tableView.dequeueReusableCellWithIdentifier("studentCell") as! UITableViewCell
            
            let datum = self.information[indexPath.row]
        
            // Set the name and image
            if datum.isValid(){
                cell.textLabel?.text = (datum.firstName + datum.lastName)
                cell.detailTextLabel?.text = datum.mediaURL
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        var actualPosition = scrollView.contentOffset.y
        var contentHeight = scrollView.contentSize.height - table.frame.size.height
        
        if(actualPosition >= contentHeight){
            // addData()
        }
    }
    
    func addData(){
        
        if(self.refresh){
            
            self.refresh = false
            
            let queue = dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.value), 0)
        
            dispatch_sync(queue) {
                OTMData.sharedInstance().fetchData(self.count, completionHandler: { (success, result) -> Void in
            
                    if success {
                        for datum in result {
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
