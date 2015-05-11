//
//  OTMStudentInformation.swift
//  OnTheMap
//
//  Created by Kinan Turjman on 5/8/15.
//  Copyright (c) 2015 Kinan Turjman. All rights reserved.
//

struct OTMStudentInformation {
    
    var lat: Double!
    var long: Double!

    init(dictionary: [String: AnyObject]){
        self.lat = dictionary["latitude"] as? Double
        self.long = dictionary["longitude"] as? Double
    }
    
    static func informationFromResults(results: [[String : AnyObject]]) -> [OTMStudentInformation] {
        
        var information = [OTMStudentInformation]()
        
        for result in results {
            information.append(OTMStudentInformation(dictionary: result))
        }
        
        return information
    }
}
