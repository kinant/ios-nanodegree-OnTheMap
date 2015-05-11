//
//  OTMConstants.swift
//  OnTheMap
//
//  Created by Kinan Turjman on 5/8/15.
//  Copyright (c) 2015 Kinan Turjman. All rights reserved.
//

import Foundation

extension OTMClient {
    
    struct UdacityAPIConstants {
        static let BaseURL: String = "https://www.udacity.com/api/"
    }
    
    struct UdacityMethods {
        static let Session = "session"
        static let Account = ""
    }
    
    struct UdacityParameterKeys {
        static let SessionID = ""
    }
    
    struct ParseAPIConstants {
        static let AppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RESTKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let BaseURL = "https://api.parse.com/1/classes/StudentLocation"
    }
    
    struct ParseAPIParameters {
        static let Limit = "limit"
        static let Count = "count"
        static let Skip = "skip"
    }
}