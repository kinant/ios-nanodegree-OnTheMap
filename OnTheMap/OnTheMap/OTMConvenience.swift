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
        
        self.getSessionID(httpBody, completionHandler: { (success, sessionID, errorString) -> Void in
            
            if success {
                self.sessionID = sessionID
                
                self.getUserList({ (success, sessionID, errorString) -> Void in
                    println("getting user list")
                })
                
            } else {
                completionHandler(success: success, errorString: errorString)
            }
            completionHandler(success: success, errorString: errorString)
        })
    }
    
    func getSessionID(httpBody: String, completionHandler: (success: Bool, sessionID: String?, errorString: String?) -> Void) {
        
        var parameters = [String : AnyObject]()
        
        taskForPOSTMethod(OTMClient.UdacityMethods.Session, parameters: parameters, httpBody: httpBody) { (result, error) -> Void in
            // println(result)
            
            if let error = error {
                completionHandler(success: false, sessionID: nil, errorString: "Login Failed (Session ID).")
            } else {
                if let sessionDictionary = result.valueForKey("session") as? NSDictionary {
                    // completionHandler(success: true, sessionID: sessionID, errorString: nil)
                    // println(sessionID)
                    let sessionID = sessionDictionary["expiration"] as? String
                    completionHandler(success: true, sessionID: sessionID, errorString: nil)
                } else {
                    completionHandler(success: false, sessionID: nil, errorString: "Login Failed (Session ID).")
                }
            }
        }
    }
    
    func getUserList(completionHandler: (success: Bool, sessionID: String?, errorString: String?) -> Void){
        
        var parameters = [
            OTMClient.ParseAPIParameters.Limit: 10
        ]
        
        taskForGetMethod("", parameters: parameters) { (result, error) -> Void in
            // println(result)
            
            if let error = error {
                completionHandler(success: false, sessionID: nil, errorString: "Parse API.")
            } else {
                println(result)
                // completionHandler(success: true, sessionID: self.sessionID, errorString: nil)
            }
        }
    }
}