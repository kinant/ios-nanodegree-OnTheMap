//
//  OTMStudentInformation.swift
//  OnTheMap
//
//  Created by Kinan Turjman on 5/8/15.
//  Copyright (c) 2015 Kinan Turjman. All rights reserved.
//

struct OTMStudentInformation {
    
    var userID: String?
    var firstName: String?
    var lastName: String?
    
    init(dictionary: [String: AnyObject]){
        self.userID = dictionary["key"] as? String
        self.firstName = dictionary["first_name"] as? String
        self.lastName = dictionary["last_name"] as? String
    }
    
}
