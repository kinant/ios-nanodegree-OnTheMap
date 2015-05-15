//
//  OTMConvinience.swift
//  OnTheMap
//
//  Created by Kinan Turjman on 5/8/15.
//  Copyright (c) 2015 Kinan Turjman. All rights reserved.
//

import Foundation
import UIKit

extension OTMClient {
    
    // MARK: - Authentication (POST) Methods
    
    func udacityLogin(hostViewController: UIViewController, username: String, password: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        var httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        
        self.getSessionID(httpBody, completionHandler: { (success, sessionID, userID, errorString) -> Void in
            
            if success {
                self.sessionID = sessionID
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
                println(result)
                
                if let sessionDictionary = result.valueForKey("session") as? NSDictionary {
                    if let accountDictionary = result.valueForKey("account") as? NSDictionary {
                        let sessionID = sessionDictionary["id"] as? String
                        let userID = accountDictionary["key"] as? String
                        
                        // println("session id is: \(sessionID)")
                        // println("user id is: \(userID)")
                        
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
    
    
    func getUserData(httpBody: String, completionHandler: (success: Bool, sessionID: String?, errorString: String?) -> Void) {
        
        var parameters = [String : AnyObject]()
        var method = "\(OTMClient.UdacityMethods.Account)/\(self.userID)"
        
        println("method will be: \(method)")
        
        taskForPOSTMethod(OTMClient.UdacityMethods.Session, parameters: parameters, httpBody: httpBody) { (result, error) -> Void in
            // println(result)
            
            if let error = error {
                completionHandler(success: false, sessionID: nil, errorString: "Login Failed (Session ID).")
            } else {
                println(result)
            }
        }
    }
    
    func getUserList(completionHandler: (result: [OTMStudentLocation]?, errorString: String?) -> Void){
        
        var parameters = [
            OTMClient.ParseAPIParameters.Limit: 10,
            OTMClient.ParseAPIParameters.Count: 0,
            OTMClient.ParseAPIParameters.Skip: currentLoadCount
        ]
        
        taskForGetMethod(OTMClient.ParseAPIConstants.BaseURL, parameters: parameters) { (result, error) -> Void in
            // println(result)
            
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
}