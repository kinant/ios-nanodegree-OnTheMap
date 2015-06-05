//
//  OTMStudentInformation.swift
//  OnTheMap
//
//  Created by Kinan Turjman on 5/8/15.
//  Copyright (c) 2015 Kinan Turjman. All rights reserved.
//

/* A struct to hold the students information */
struct OTMStudentInformation {
    
    var userID: String? // student's Udacity ID Key
    var firstName: String?
    var lastName: String?
    
    /* Initialize an user */
    init(userID: String, fName: String, lName: String){
        self.userID = userID
        self.firstName = fName
        self.lastName = lName
    }
}
