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
    
    func login(hostViewController: UIViewController, api: OTMAPIs ,username: String, password: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        var httpBody:String!
        
        switch api {
        
        case .Udacity:
            httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        case .Facebook:
            httpBody = "{\"facebook_mobile\": {\"access_token\": \"\(FBaccessToken!)\"}}"
        default:
            httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        }
        
        self.getSessionID(httpBody, completionHandler: { (success, sessionID, userID, errorString) -> Void in
            
            if success {
                self.sessionID = sessionID!
                self.userID = userID!
                
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
        
        taskForPOSTandPUTDataMethod(OTMAPIs.Udacity, baseURL: OTMClient.UdacityAPIConstants.BaseURL, method: OTMClient.UdacityMethods.Session, parameters: parameters, httpBody: httpBody, updatingID: "") { (result, error) -> Void in
            
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
        
        taskForGETDataMethod(OTMAPIs.Udacity, baseURL: UdacityAPIConstants.BaseURL , method: method, parameters: parameters) { (result, error) -> Void in
            
            if let error = error {
                completionHandler(success: false, fName: "", lName: "", errorString: "Udacity API")
            } else {
                // println(result)
                if let resultDictionary = result["user"] as? NSDictionary {
                    var firstName = resultDictionary["first_name"] as? String
                    var lastName = resultDictionary["last_name"] as? String
                    completionHandler(success: true, fName: firstName, lName: lastName, errorString: nil)
                }
            }
        }
    }
    
    func fetchLocations(skip: Int, completionHandler: (result: [OTMStudentLocation]?, errorString: String?) -> Void){
        
        var parameters = [
            OTMClient.ParseAPIParameters.Limit: OTMClient.ParseAPIConstants.LimitPerRequest,
            OTMClient.ParseAPIParameters.Count: 0,
            OTMClient.ParseAPIParameters.Skip: skip,
        ]
        
        taskForGETDataMethod(OTMAPIs.Parse, baseURL: ParseAPIConstants.BaseURL , method: "", parameters: parameters) { (result, error) -> Void in
            
            if let error = error {
                completionHandler(result: nil, errorString: "Parse API.")
            } else {
                
                if let results = result.valueForKey("results") as? [[String: AnyObject]] {
                    var newInformation = OTMStudentLocation.informationFromResults(results)
                    completionHandler(result: newInformation , errorString: nil)
                }
            }
        }
    }
    
    func getLocationsCount(completionHandler: (result: Int, errorString: String?) -> Void){
        var parameters = [
            OTMClient.ParseAPIParameters.Limit: 0,
            OTMClient.ParseAPIParameters.Count: 1,
            OTMClient.ParseAPIParameters.Skip: 0,
        ]
        
        taskForGETDataMethod(OTMAPIs.Parse, baseURL: ParseAPIConstants.BaseURL , method: "", parameters: parameters) { (result, error) -> Void in
            
            if let error = error {
                completionHandler(result: 0, errorString: "Parse API.")
            } else {
                
                if let count = result.valueForKey("count") as? Int {
                    println("count is: \(count)")
                    completionHandler(result: count, errorString: nil)
                }
            }
        }
    }
    
    func postUserLocation(lat: Double, long: Double, mediaURL: String, mapString: String, updateLocationID: String, completionHandler: (result: String?, errorString: String?) -> Void)
    {
        var parameters = [String : AnyObject]()
        
        var httpBody = "{\"uniqueKey\": \"\(self.userID!)\",\"firstName\": \"\(self.student.firstName!)\",\"lastName\": \"\(self.student.lastName!)\", \"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(lat), \"longitude\": \(long)}"
        
        taskForPOSTandPUTDataMethod(OTMAPIs.Parse, baseURL: OTMClient.ParseAPIConstants.BaseURL, method: "", parameters: parameters, httpBody: httpBody, updatingID: updateLocationID) { (result, error) -> Void in
        }
    }
    
    func userLocationExists(completionHandler: (exists: Bool, objectID: String) -> Void) {
    
        var locationExits = false
        var existingLocation: String = ""
        
        var parameters = [
            "where": "{\"uniqueKey\":\"\(userID!)\"}"
        ]
        
        taskForGETDataMethod(OTMAPIs.Parse, baseURL: ParseAPIConstants.BaseURL , method: "", parameters: parameters) { (result, error) -> Void in
            
            if let resultsDictionary = result.valueForKey("results") as? [[String: AnyObject]] {
                
                if resultsDictionary.count > 0 {
                    existingLocation = (resultsDictionary[0]["objectId"] as? String)!
                    println(existingLocation)
                    locationExits = true
                    completionHandler(exists: true, objectID: existingLocation)
                    return
                } else {
                    completionHandler(exists: false, objectID: "")
                }
            }
        }
    }
}