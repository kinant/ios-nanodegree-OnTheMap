//
//  OTMConstants.swift
//  OnTheMap
//
//  Created by Kinan Turjman on 5/8/15.
//  Copyright (c) 2015 Kinan Turjman. All rights reserved.
//

import Foundation

extension OTMClient {
    
    struct OTMAPIs {
        static let FacebookAPI = "Facebook"
        static let UdacityAPI = "Udacity"
        static let ParseAPI = "Parse"
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
}