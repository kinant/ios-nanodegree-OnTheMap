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
    
    var information: [OTMStudentLocation] = [OTMStudentLocation]()
    var count: Int!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        addData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.information.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("studentCell") as! UITableViewCell
        let datum = self.information[indexPath.row]
        
        // Set the name and image
        cell.textLabel?.text = (datum.firstName + datum.lastName)
        cell.detailTextLabel?.text = datum.mediaURL
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        // println("loading more data!!")
        
        var actualPosition = scrollView.contentOffset.y
        var contentHeight = scrollView.contentSize.height - table.frame.size.height
        
        if(actualPosition >= contentHeight){
            addData()
        }
    }
    
    func addData(){
        
        OTMClient.sharedInstance().fetchLocations { (result, errorString) -> Void in
            // println(result)
            
            for datum in result! {
                self.information.append(datum)
            }
        }
        
        self.table.reloadData()
    }
    
}
