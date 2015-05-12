//
//  StudentInfoTableViewController.swift
//  OnTheMap
//
//  Created by Kinan Turjman on 5/12/15.
//  Copyright (c) 2015 Kinan Turjman. All rights reserved.
//

import UIKit

class StudentInfoTableViewController: UITableViewController, UITableViewDataSource {
    
    var data = [1,2,3,4,5,6,7,8,9,10]
    
    // MARK: Table View Data Source
    
    @IBOutlet var table: UITableView!
    
    var information: [OTMStudentInformation] = [OTMStudentInformation]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        
        OTMClient.sharedInstance().getUserList { (result, errorString) -> Void in
            println(result)
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("studentCell") as! UITableViewCell
        let datum = self.data[indexPath.row]
        
        // Set the name and image
        cell.textLabel?.text = String(datum)
        cell.detailTextLabel?.text = "test2"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        println("loading more data!!")
        
        var actualPosition = scrollView.contentOffset.y
        var contentHeight = scrollView.contentSize.height - table.frame.size.height
        
        if(actualPosition >= contentHeight){
            addData()
        }
    }
    
    func addData(){
        
        let total = data.count + 11
        
        for(var i = (data.count + 1); i < total; i++){
            data.append(i)
        }
        
        self.table.reloadData()
    }
    
}
