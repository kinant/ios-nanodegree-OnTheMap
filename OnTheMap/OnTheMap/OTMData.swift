//
//  OTMData.swift
//  OnTheMap
//
//  Created by KT on 5/21/15.
//  Copyright (c) 2015 Kinan Turjman. All rights reserved.
//

import Foundation

// This is the class used to store the apps Student Locations data
class OTMData: NSObject {
    
    var locationsList = [OTMStudentLocation]() // array to hold student locations
    
    // function to fetch data from the internet
    func fetchData(view: UIViewController, skip: Int, completionHandler: (result: [OTMStudentLocation]?) -> Void){
        
        // call the client function
        OTMClient.sharedInstance().fetchLocations(skip) { (result, error) -> Void in
            
            // check for error
            if let dataError = error {
            
                // if there is an error, check that no error has already been presented, present alert
                if view.presentedViewController == nil {
                    OTMClient.sharedInstance().showAlert(view, title: dataError.domain, message: dataError.localizedDescription, actions: ["OK"], completionHandler: { (choice) -> Void in
                        
                        // there was an error, completion handler sent with nil
                        completionHandler(result: nil)
                    })
                }
            }
            
            // no errors, check for returned data
            if let fetchedData = result {
                
                // array to store the newly fetched data
                var newData = [OTMStudentLocation]()
                
                // make sure that the count of the results is more than 0
                if(fetchedData.count > 0){
                    
                    // iterate over each element
                    for datum in fetchedData {
                        
                        // append to apps data
                        self.locationsList.append(datum)
                        
                        // append to new data array
                        newData.append(datum)
                    }
                }
                
                // completion handler, sending ONLY the new data (for batched and paged requests)
                completionHandler(result: newData)
            }
            //activityIndicatorEnabled(false)
        }
        
    }
    
    // function to create the singleton
    class func sharedInstance() -> OTMData {
        
        struct Singleton {
            static var sharedInstance = OTMData()
        }
        
        return Singleton.sharedInstance
    }
}