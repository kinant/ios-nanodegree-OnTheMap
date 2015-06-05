//
//  OTMConstants.swift
//  OnTheMap
//
//  Created by Kinan Turjman on 5/8/15.
//  Copyright (c) 2015 Kinan Turjman. All rights reserved.
//

import Foundation
import MapKit

/* Extension of OTMClient for all the app's constants */
extension OTMClient {
    
    // APIs
    enum OTMAPIs {
        case Udacity
        case Parse
        case Facebook
    }
    
    // Location of Udacity HQ
    static var UdacityHQLocation: CLLocation {
        get {
            return CLLocation(latitude: 37.400704, longitude: -122.108284)
        }
    }
    
    struct UdacityAPIConstants {
        static let BaseURL: String = "https://www.udacity.com/api/"
    }
    
    struct UdacityMethods {
        static let Session = "session"
        static let Account = "users"
    }
    
    struct UdacityParameterKeys {
        static let SessionID = ""
    }
    
    struct ParseAPIConstants {
        static let AppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RESTKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let BaseURL = "https://api.parse.com/1/classes/StudentLocation"
        static let LimitPerRequest = 10
    }
    
    struct ParseAPIParameters {
        static let Limit = "limit"
        static let Count = "count"
        static let Skip = "skip"
    }
    
    struct ParseObjectConstants {
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let MapString = "mapString"
        static let MediURL = "mediaURL"
    }
    
    // App errors to display when an error occurs that is neither a connection nor a server-side error
    struct OTMErrors {
        static let udacitySession = NSError(domain: "OTM Error", code: 1, userInfo: [NSLocalizedDescriptionKey : "Login Failed (Session ID)"])
        static let udacityUser = NSError(domain: "OTM Error", code: 2, userInfo: [NSLocalizedDescriptionKey : "Login Failed (User Data)"])
        static let parseFetchLocations = NSError(domain: "OTM Error", code: 3, userInfo: [NSLocalizedDescriptionKey : "Parse Fetching Locations Failed"])
        static let parseFetchCount = NSError(domain: "OTM Error", code: 4, userInfo: [NSLocalizedDescriptionKey : "Parse Fetching Count Failed"])
        static let parsePostLocation = NSError(domain: "OTM Error", code: 5, userInfo: [NSLocalizedDescriptionKey : "Parse Post Location Failed"])
        static let parseQuery = NSError(domain: "OTM Error", code: 6, userInfo: [NSLocalizedDescriptionKey : "Parse Query User Failed"])
    }
}