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
    
    func fetchData(view: UIViewController, skip: Int, completionHandler: (result: [OTMStudentLocation]?) -> Void){
        
        OTMClient.sharedInstance().fetchLocations(skip) { (result, error) -> Void in
            
            if let dataError = error {
            
                if view.presentedViewController == nil {
                    OTMClient.sharedInstance().showAlert(view, title: dataError.domain, message: dataError.localizedDescription, actions: ["OK"], completionHandler: { (choice) -> Void in
                        completionHandler(result: nil)
                    })
                }
            }
            
            if let fetchedData = result {
                
                var newData = [OTMStudentLocation]()
                
                if(result!.count > 0){
                    
                    for datum in fetchedData {
                        self.locationsList.append(datum)
                        newData.append(datum)
                    }
                }
                
                completionHandler(result: newData)
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