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


/* Extension of the OTMClient class. This extension holds all the functions that the app uses for network requests and manages all the completion handlers for all sorts of app functions */
extension OTMClient {
    
    /* Logs the user in */
    func login(hostViewController: UIViewController, api: OTMAPIs ,username: String, password: String, completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        // set the http body based on the API being used
        var httpBody:String!
        
        switch api {
        
        case .Udacity:
            httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        case .Facebook:
            httpBody = "{\"facebook_mobile\": {\"access_token\": \"\(FBaccessToken!)\"}}"
        default:
            httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        }
        
        // make the request to get the session id
        self.getSessionID(httpBody, completionHandler: { (success, sessionID, userID, error) -> Void in
            
            // if successfull, set the session ID and user ID
            if success {
                self.sessionID = sessionID!
                self.userID = userID!
                
                // proceed to make the request for the user data
                self.getUserData("", completionHandler: { (success, fName, lName, errorString) -> Void in
                    
                    // if successfull, set the user's data
                    if success {
                        self.student = OTMStudentInformation(userID: self.userID!, fName: fName!, lName: lName!)
                    } else {
                        // not successfull
                        completionHandler(success: success, error: error)
                    }
                })
            } else {
                // handle session ID not being successfull
                completionHandler(success: success, error: error)
            }
            
            // call completion handler, everything was successful hopefully...
            completionHandler(success: success, error: error)
        })
    }
    
    /* requests the Udacity Session ID */
    func getSessionID(httpBody: String, completionHandler: (success: Bool, sessionID: String?, userID: String?, error: NSError?) -> Void) {
    
        // set the parameters
        var parameters = [String : AnyObject]()
        
        // make the request
        taskForPOSTandPUTDataMethod(OTMAPIs.Udacity, baseURL: OTMClient.UdacityAPIConstants.BaseURL, method: OTMClient.UdacityMethods.Session, parameters: parameters, httpBody: httpBody, updatingID: "") { (result, error) -> Void in
            
            // check for errors
            if let error = error {
                completionHandler(success: false, sessionID: nil, userID: nil, error: error)
            } else {
                
                // no errors, obtain the relevant objects from the result
                if let sessionDictionary = result.valueForKey("session") as? NSDictionary {
                    if let accountDictionary = result.valueForKey("account") as? NSDictionary {
                        
                        // set the session id and user id
                        let sessionID = sessionDictionary["id"] as? String
                        let userID = accountDictionary["key"] as? String
                        
                        // call completion handler successfully
                        completionHandler(success: true, sessionID: sessionID, userID: userID, error: nil)
                    }
                    else {
                        // handle error with account dictionary
                        completionHandler(success: false, sessionID: nil, userID: nil, error: OTMErrors.udacitySession)
                    }
                } else {
                    // handle error with session dictionary
                    completionHandler(success: false, sessionID: nil, userID: nil, error: OTMErrors.udacitySession)
                }
            }
        }
    }
    
    /* Get's the users data from the Udacity API */
    func getUserData(httpBody: String, completionHandler: (success: Bool, fName: String?, lName: String?, error: NSError?) -> Void) {
        
        // set the parameters and method
        var parameters = [String : AnyObject]()
        var method = "\(OTMClient.UdacityMethods.Account)/\(self.userID!)"
        
        // make the request
        taskForGETDataMethod(OTMAPIs.Udacity, baseURL: UdacityAPIConstants.BaseURL , method: method, parameters: parameters) { (result, error) -> Void in
            
            // check for errors and handle
            if let error = error {
                completionHandler(success: false, fName: "", lName: "", error: error)
            } else {
                // no errors, check for relevant objects in results
                if let resultDictionary = result["user"] as? NSDictionary {
                    
                    // set the user's name
                    var firstName = resultDictionary["first_name"] as? String
                    var lastName = resultDictionary["last_name"] as? String
                    
                    // call completion handler successfully
                    completionHandler(success: true, fName: firstName, lName: lastName, error: nil)
                }
                else {
                    // handle error with results dictionary
                    completionHandler(success: false, fName: "", lName: "", error: OTMErrors.udacityUser)
                }
            }
        }
    }
    
    /* Get's the student locations from Parse API. This returns a single batch of results, determined by skip parameter */
    func fetchLocations(skip: Int, completionHandler: (result: [OTMStudentLocation]?, error: NSError?) -> Void){
        
        // set parameters
        var parameters = [
            OTMClient.ParseAPIParameters.Limit: OTMClient.ParseAPIConstants.LimitPerRequest, // the limit of results returned
            OTMClient.ParseAPIParameters.Count: 0, // not applicable (used for count)
            OTMClient.ParseAPIParameters.Skip: skip, // the amount of items to skip
        ]
        
        // make the request
        taskForGETDataMethod(OTMAPIs.Parse, baseURL: ParseAPIConstants.BaseURL , method: "", parameters: parameters) { (result, error) -> Void in
            
            // handle the error
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                // no error, get relevant objects from result
                if let results = result.valueForKey("results") as? [[String: AnyObject]] {
                    
                    // get the new locations array from the results
                    var newInformation = OTMStudentLocation.informationFromResults(results)
                    completionHandler(result: newInformation , error: nil)
                } else {
                    // handle error with results
                    completionHandler(result: nil , error: OTMErrors.parseFetchLocations)
                }
            }
        }
    }
    
    /* Get's a total count of the student locations in the Parse API */
    func getLocationsCount(completionHandler: (result: Int, error: NSError?) -> Void){
        
        // set the parameters to get the count (as defined in Parse API Documentation)
        var parameters = [
            OTMClient.ParseAPIParameters.Limit: 0,
            OTMClient.ParseAPIParameters.Count: 1,
            OTMClient.ParseAPIParameters.Skip: 0,
        ]
        
        // make the request
        taskForGETDataMethod(OTMAPIs.Parse, baseURL: ParseAPIConstants.BaseURL , method: "", parameters: parameters) { (result, error) -> Void in
            
            // handle error
            if let error = error {
                completionHandler(result: 0, error: error)
            } else {
                
                // check for count object
                if let count = result.valueForKey("count") as? Int {
                    // successfull
                    completionHandler(result: count, error: nil)
                } else {
                    // handle error for no key found
                    completionHandler(result: 0 , error: OTMErrors.parseFetchCount)
                }
            }
        }
    }
    
    /* Post or update user's location to the Parse API. It will update if parameter updateLocationID is not "" (empty) */
    func postUserLocation(lat: Double, long: Double, mediaURL: String, mapString: String, updateLocationID: String, completionHandler: (error: NSError?) -> Void)
    {
        // set parameters
        var parameters = [String : AnyObject]()
        
        // set the http body
        var httpBody = "{\"uniqueKey\": \"\(self.userID!)\",\"firstName\": \"\(self.student!.firstName!)\",\"lastName\": \"\(self.student!.lastName!)\", \"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(lat), \"longitude\": \(long)}"
        
        // make the request
        taskForPOSTandPUTDataMethod(OTMAPIs.Parse, baseURL: OTMClient.ParseAPIConstants.BaseURL, method: "", parameters: parameters, httpBody: httpBody, updatingID: updateLocationID) { (result, error) -> Void in
            
                // we do nothing with the result, so we only handle the error (it will be nil if all went well)
                completionHandler(error: error)
        }
    }
    
    /* Used to determine if a user has already posted a location. This way, we will then only update the location */
    func userLocationExists(completionHandler: (exists: Bool, objectID: String, error: NSError?) -> Void) {
    
        // set ID of existing location
        var existingLocationID: String = ""
        
        // set the query parameters
        var parameters = [
            "where": "{\"uniqueKey\":\"\(userID!)\"}"
        ]
        
        // make the request
        taskForGETDataMethod(OTMAPIs.Parse, baseURL: ParseAPIConstants.BaseURL , method: "", parameters: parameters) { (result, error) -> Void in
            
            // handle errors
            if let error = error {
                completionHandler(exists: false, objectID: " ", error: error)
            } else {
                // no errors, check for relevant objects
                if let resultsDictionary = result.valueForKey("results") as? [[String: AnyObject]] {
                    
                    // check if the results count is greater than 0, if it is then user has location(s) posted
                    if resultsDictionary.count > 0 {
                        
                        // get the ID of the first location from the results
                        existingLocationID = (resultsDictionary[0]["objectId"] as? String)!
                        
                        // call completion handler with successful query for user location
                        completionHandler(exists: true, objectID: existingLocationID, error: nil)
                        return
                    
                    } else {
                        
                        // call completion handler for case in which user location does not exist
                        completionHandler(exists: false, objectID: "", error: nil)
                    }
                } else {
                    
                    // call completion handler with error due to key not found in results
                    completionHandler(exists: false, objectID: "", error: OTMErrors.parseQuery)
                }
            }
        }
    }
    
    /* Used to delete a location... not implemented directly into app. Used only for development side */
    func deleteLocation(completionHandler: (success: Bool, error: NSError?) -> Void) {
    
        var parameters = [String: AnyObject]()
        
        var objectIDtoDelete: String!
        
        userLocationExists { (exists, objectID, error) -> Void in
            
            if error != nil {
                completionHandler(success: false, error: error)
            }
            
            if exists {
                objectIDtoDelete = objectID
                
                self.taskForDelete(OTMAPIs.Parse, baseURL: ParseAPIConstants.BaseURL, method: objectIDtoDelete, parameters: parameters, completionHandler: { (success, error) -> Void in
                  
                    if success {
                        completionHandler(success: true, error: nil)
                        //println("user location successfully deleted!")
                    }
                })
            }
        }
    }
    
    /* Logs the user out */
    func logout(completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        // set parameters
        var parameters = [String: AnyObject]()
        
        // make the request
        taskForDelete(OTMAPIs.Udacity, baseURL: UdacityAPIConstants.BaseURL, method: UdacityMethods.Session, parameters: parameters) { (success, error) -> Void in
         
            // handle errors
            if error != nil {
                completionHandler(success: false, error: error)
            }
            
            // check if logout was successful
            if success {
                
                // reset the clients properties
                self.sessionID = nil
                self.userID = nil
                self.student = OTMStudentInformation?()
                
                // call completion handler with successfull sign-out
                completionHandler(success: true, error: nil)
            }
        }
    }
}