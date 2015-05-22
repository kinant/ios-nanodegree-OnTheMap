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
    
    func fetchData(skip: Int, completionHandler: (result: [OTMStudentLocation]) -> Void){
        
        OTMClient.sharedInstance().fetchLocations(skip) { (result, errorString) -> Void in
            if let fetchedData = result {
                for datum in fetchedData {
                    self.locationsList.append(datum)
                }
                completionHandler(result: self.locationsList)
            }

        }
    
    /*
        if let fetchedData = result {
            for datum in fetchedData {
                self.locationsList.append(datum)
            }
            completionHandler(result: self.locationsList)
        }
    */
    
    }
    
    class func sharedInstance() -> OTMData {
        
        struct Singleton {
            static var sharedInstance = OTMData()
        }
        
        return Singleton.sharedInstance
    }
}