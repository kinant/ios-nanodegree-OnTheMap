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
    var name: String?
    var mediaURL: String?
    
    init(dictionary: [String: AnyObject]){
        
        // println(dictionary)
        
        self.lat = dictionary["latitude"] as? Double
        self.long = dictionary["longitude"] as? Double
        
        var fName = dictionary["firstName"] as? String
        var lName = dictionary["lastName"] as? String
        
        self.name = "\(fName!) \(lName!)"
        
        println(self.name)
    
        self.mediaURL = dictionary["mediaURL"] as? String
    }
    
    static func informationFromResults(results: [[String : AnyObject]]) -> [OTMStudentInformation] {
        
        var information = [OTMStudentInformation]()
        
        for result in results {
            information.append(OTMStudentInformation(dictionary: result))
        }
        
        return information
    }
}
