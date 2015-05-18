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
    
    init(userID: String, fName: String, lName: String){
        self.userID = userID
        self.firstName = fName
        self.lastName = lName
    }
}
