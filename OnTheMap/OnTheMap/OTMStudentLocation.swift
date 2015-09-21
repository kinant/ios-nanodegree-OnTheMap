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
    
    // MARK: Properties
    // struct properties based on what is stored online in Parse API
    var uniqueKey: String!
    var firstName: String!
    var lastName: String!
    var mapString: String!
    var mediaURL: String!
    var latitude: Double!
    var longitude: Double!
    var distance: Double!
    
    // MARK: init
    // initializer for a Student location, takes in a dictionary
    init(dictionary: [String: AnyObject]){
        
        // set the properties
        self.latitude = dictionary[OTMClient.ParseStudentObjectConstants.Latitude] as? Double
        self.longitude = dictionary[OTMClient.ParseStudentObjectConstants.Longitude] as? Double
        self.firstName = dictionary[OTMClient.ParseStudentObjectConstants.FirstName] as? String
        self.lastName = dictionary[OTMClient.ParseStudentObjectConstants.LastName] as? String
        self.mediaURL = dictionary[OTMClient.ParseStudentObjectConstants.MediURL] as? String
        self.mapString = dictionary[OTMClient.ParseStudentObjectConstants.MapString] as? String
        self.uniqueKey = dictionary[OTMClient.ParseStudentObjectConstants.UniqueKey] as? String
        
        // calculate the distance of this student's location to Udacity HQ (in km)
        let location = CLLocation(latitude: self.latitude, longitude: self.longitude)
        self.distance = location.distanceFromLocation(OTMClient.UdacityHQLocation)/1000
    }
    
    // MARK: FUNCTIONS
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