//
//  OTMStudentLocation.swift
//  OnTheMap
//
//  Created by KT on 5/15/15.
//  Copyright (c) 2015 Kinan Turjman. All rights reserved.
//

import Foundation
import MapKit

/* Struct for a student's location */
struct OTMStudentLocation {
    
    // struct properties based on what is stored online in Parse API
    var uniqueKey: String!
    var firstName: String!
    var lastName: String!
    var mapString: String!
    var mediaURL: String!
    var latitude: Double!
    var longitude: Double!
    var distance: Double!
    
    // initializer for a Student location, takes in a dictionary
    init(dictionary: [String: AnyObject]){
        
        // set the properties
        self.latitude = dictionary["latitude"] as? Double
        self.longitude = dictionary["longitude"] as? Double
        self.firstName = dictionary["firstName"] as? String
        self.lastName = dictionary["lastName"] as? String
        self.mediaURL = dictionary["mediaURL"] as? String
        self.mapString = dictionary["mapString"] as? String
        self.uniqueKey = dictionary["uniqueKey"] as? String
        
        // calculate the distance of this student's location to Udacity HQ (in km)
        var location = CLLocation(latitude: self.latitude, longitude: self.longitude)
        self.distance = location.distanceFromLocation(OTMClient.UdacityHQLocation)/1000
    }
    
    // returns an array of student locations given an array of results
    static func informationFromResults(results: [[String : AnyObject]]) -> [OTMStudentLocation] {
        
        var information = [OTMStudentLocation]()
        
        for result in results {
            information.append(OTMStudentLocation(dictionary: result))
        }
        
        return information
    }
    
    /* used to check if an OTMStudentLocation object is valid (since we can't guarantee that all student apps create valid objects) */
    func isValid() -> Bool
    {
        if(self.latitude != nil && self.longitude != nil && self.firstName != nil && self.lastName != nil && self.mediaURL != nil && self.mapString != nil && self.uniqueKey != nil){
            return true
        }
        return false
    }
}