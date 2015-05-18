//
//  OTMStudentLocation.swift
//  OnTheMap
//
//  Created by KT on 5/15/15.
//  Copyright (c) 2015 Kinan Turjman. All rights reserved.
//

import Foundation

struct OTMStudentLocation {
    
    var uniqueKey: String!
    var firstName: String!
    var lastName: String!
    var mapString: String!
    var mediaURL: String!
    var latitude: Double!
    var longitude: Double!
    
    init(dictionary: [String: AnyObject]){
        
        // println(dictionary)
        
        self.latitude = dictionary["latitude"] as? Double
        self.longitude = dictionary["longitude"] as? Double
        self.firstName = dictionary["firstName"] as? String
        self.lastName = dictionary["lastName"] as? String
        self.mediaURL = dictionary["mediaURL"] as? String
        self.mapString = dictionary["mapString"] as? String
        self.uniqueKey = dictionary["uniqueKey"] as? String
    }
    
    static func informationFromResults(results: [[String : AnyObject]]) -> [OTMStudentLocation] {
        
        var information = [OTMStudentLocation]()
        
        for result in results {
            information.append(OTMStudentLocation(dictionary: result))
        }
        
        return information
    }
}