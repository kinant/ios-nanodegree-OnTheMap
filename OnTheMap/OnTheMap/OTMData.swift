//
//  OTMData.swift
//  OnTheMap
//
//  Created by KT on 5/21/15.
//  Copyright (c) 2015 Kinan Turjman. All rights reserved.
//

import Foundation

class OTMData: NSObject {

    var locationsList = [OTMStudentLocation]()
    
    func fetchData(skip: Int, completionHandler: (success: Bool, result: [OTMStudentLocation]) -> Void){
        
        // println("initial count: ")
        // println(self.locationsList.count)
        
        OTMClient.sharedInstance().fetchLocations(skip) { (result, errorString) -> Void in
            
            // println("sent result is: \(result)")
            
            self.locationsList.removeAll()
            
            if let fetchedData = result {
                
                if(result!.count > 0){
                    for datum in fetchedData {
                        self.locationsList.append(datum)
                    }
                    // println("result count being sent:  \(self.locationsList.count))")
                    // println("result count being received:  \(result!.count)")
                    
                    completionHandler(success: true, result: self.locationsList)
                } else {
                    completionHandler(success: false, result: self.locationsList)
                    println("no more results!")
                }
            }
        }
    }
    
    class func sharedInstance() -> OTMData {
        
        struct Singleton {
            static var sharedInstance = OTMData()
        }
        
        return Singleton.sharedInstance
    }
}