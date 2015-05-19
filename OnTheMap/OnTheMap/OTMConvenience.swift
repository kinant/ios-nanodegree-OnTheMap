//
//  OTMConvinience.swift
//  OnTheMap
//
//  Created by Kinan Turjman on 5/8/15.
//  Copyright (c) 2015 Kinan Turjman. All rights reserved.
//

// my id for testing: 1612749455

import Foundation
import UIKit

extension OTMClient {
    
    // MARK: - Authentication (POST) Methods
    
    func udacityLogin(hostViewController: UIViewController, username: String, password: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        var httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        
        self.getSessionID(httpBody, completionHandler: { (success, sessionID, userID, errorString) -> Void in
            
            if success {
                self.sessionID = sessionID!
                self.userID = userID!
                
                println(userID!)
                
                self.getUserData("", completionHandler: { (success, fName, lName, errorString) -> Void in
                    
                    if success {
                        self.student = OTMStudentInformation(userID: self.userID!, fName: fName!, lName: lName!)
                    }
                    
                })
                
            } else {
                completionHandler(success: success, errorString: errorString)
            }
            completionHandler(success: success, errorString: errorString)
        })
    }
    
    func getSessionID(httpBody: String, completionHandler: (success: Bool, sessionID: String?, userID: String?, errorString: String?) -> Void) {
        
        var parameters = [String : AnyObject]()
        
        taskForPOSTMethod(OTMClient.UdacityMethods.Session, parameters: parameters, httpBody: httpBody) { (result, error) -> Void in
            
            if let error = error {
                completionHandler(success: false, sessionID: nil, userID: nil, errorString: "Login Failed (Session ID).")
            } else {
                
                if let sessionDictionary = result.valueForKey("session") as? NSDictionary {
                    if let accountDictionary = result.valueForKey("account") as? NSDictionary {
                        let sessionID = sessionDictionary["id"] as? String
                        let userID = accountDictionary["key"] as? String
                        
                        completionHandler(success: true, sessionID: sessionID, userID: userID, errorString: nil)
                    }
                    else {
                        completionHandler(success: false, sessionID: nil, userID: nil, errorString: "Login Failed (Session ID).")
                    }
                } else {
                    completionHandler(success: false, sessionID: nil, userID: nil, errorString: "Login Failed (Session ID).")
                }
            }
        }
    }
    
    
    func getUserData(httpBody: String, completionHandler: (success: Bool, fName: String?, lName: String?, errorString: String?) -> Void) {
        
        var parameters = [String : AnyObject]()
        var method = "\(OTMClient.UdacityMethods.Account)/\(self.userID!)"
        
        taskForGetUserMethod(method, parameters: parameters) { (result, error) -> Void in
            
            if let error = error {
                completionHandler(success: false, fName: "", lName: "", errorString: "Udacity API")
            } else {
                
                if let resultDictionary = result["user"] as? NSDictionary {
                    var firstName = resultDictionary["first_name"] as? String
                    var lastName = resultDictionary["last_name"] as? String
                    completionHandler(success: true, fName: firstName, lName: lastName, errorString: nil)
                }
            }
        }
    }
    
    func getUserList(completionHandler: (result: [OTMStudentLocation]?, errorString: String?) -> Void){
        
        var parameters = [
            OTMClient.ParseAPIParameters.Limit: 1000,
            OTMClient.ParseAPIParameters.Count: 0,
            OTMClient.ParseAPIParameters.Skip: currentLoadCount
        ]
        
        taskForGetMethod(OTMClient.ParseAPIConstants.BaseURL, parameters: parameters) { (result, error) -> Void in
            
            if let error = error {
                completionHandler(result: nil, errorString: "Parse API.")
            } else {
                if let results = result.valueForKey("results") as? [[String: AnyObject]] {
                    
                    var newInformation = OTMStudentLocation.informationFromResults(results)
                    
                    self.currentLoadCount += newInformation.count
                    
                    completionHandler(result: newInformation , errorString: nil)
                }
            }
        }
    }
    
    func postUserLocation(lat: Double, long: Double, mediaURL: String, mapString: String, completionHandler: (result: String?, errorString: String?) -> Void)
    {
        var parameters = [String : AnyObject]()
        
        var httpBody = "{\"uniqueKey\": \"\(self.userID!)\",\"firstName\": \"\(self.student.firstName!)\",\"lastName\": \"\(self.student.lastName!)\", \"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(lat), \"longitude\": \(long)}"
        
        taskForPOSTDataMethod("", parameters: parameters, httpBody: httpBody) { (result, error) -> Void in
            // println(result)
        }
    }
    
    func updateUserLocation(lat: Double, long: Double, mediaURL: String, mapString: String, completionHandler: (result: String?, errorString: String?) -> Void)
    {
        var parameters = [String : AnyObject]()
        
        var httpBody = "{\"uniqueKey\": \"\(self.userID!)\",\"firstName\": \"\(self.student.firstName!)\",\"lastName\": \"\(self.student.lastName!)\", \"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(lat), \"longitude\": \(long)}"
        
        taskForPOSTDataMethod("", parameters: parameters, httpBody: httpBody) { (result, error) -> Void in
            // println(result)
        }
    }
    
    func updateLocation(){
        taskForPUTMethod()
    }
    
    func lookForStudentLocation(){
        // taskForQuery()
    }
    
    func userLocationExists() -> Bool {
        
        var locationExits = false
        
        var parameters = [String : AnyObject]()
        
        println()
        println()
        println()
        
        taskForQuery("", parameters: parameters) { (result, error) -> Void in
            
            println("attempting to see if results exist!")
            // println(result)
            
            if let resultsDictionary = result.valueForKey("results") as? [[String: AnyObject]] {
                
                println(resultsDictionary)
                
                if resultsDictionary.count > 0 {
                   println("result already exists!!!")
                locationExits = true
                }
                else {
                    println("result does not exist!")
                }
            }
        }
        
        println()
        println()
        println()
        
        return locationExits
    }
}