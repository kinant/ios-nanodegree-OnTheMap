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
    
    func fetchData(){
        
        OTMClient.sharedInstance().fetchLocations { (result, errorString) -> Void in
            
            println(result)
            
            if let fetchedData = result {
                for datum in fetchedData {
                    println(datum)
                    
                        self.locationsList.append(datum)
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