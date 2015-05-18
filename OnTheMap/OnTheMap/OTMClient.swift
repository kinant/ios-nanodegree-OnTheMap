//
//  OTMClient.swift
//  OnTheMap
//
//  Created by Kinan Turjman on 5/8/15.
//  Copyright (c) 2015 Kinan Turjman. All rights reserved.
//

import Foundation

class OTMClient: NSObject {

    var session: NSURLSession
    
    var userID: String? = nil
    
    var sessionID: String? = nil
    
    var currentLoadCount = 0
    
    var student: OTMStudentInformation!
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    func taskForPOSTDataMethod(method: String, parameters: [String : AnyObject], httpBody: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
    
        let urlString = ParseAPIConstants.BaseURL
        let url = NSURL(string: urlString)!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = httpBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        request.addValue(OTMClient.ParseAPIConstants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(OTMClient.ParseAPIConstants.RESTKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            // let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            // println(NSString(data: data, encoding: NSUTF8StringEncoding))
            
            if error != nil { // Handle error…
                completionHandler(result: nil, error: error)
            } else {
                OTMClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        
        task.resume()
        
        return task
    
    }
    
    func taskForPOSTMethod(method: String, parameters: [String : AnyObject], httpBody: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let urlString = UdacityAPIConstants.BaseURL + UdacityMethods.Session
        let url = NSURL(string: urlString)!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = httpBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            // println(NSString(data: newData, encoding: NSUTF8StringEncoding))
            
            if error != nil { // Handle error…
                completionHandler(result: nil, error: error)
            } else {
                OTMClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            }
        }
        
        task.resume()
        
        return task
    }

    func taskForGetMethod(method: String, parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let urlString = ParseAPIConstants.BaseURL + OTMClient.escapedParameters(parameters)
        // let urlString = ParseAPIConstants.BaseURL

        let url = NSURL(string: urlString)!
        
        let request = NSMutableURLRequest(URL: url)
        
        request.addValue(OTMClient.ParseAPIConstants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(OTMClient.ParseAPIConstants.RESTKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
        
            // println(NSString(data: data, encoding: NSUTF8StringEncoding))
            
            if error != nil { // Handle error…
                completionHandler(result: nil, error: error)
            } else {
                OTMClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        
        task.resume()
    
        return task
    }
    
    func taskForGetUserMethod(method: String, parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let urlString = UdacityAPIConstants.BaseURL + method + OTMClient.escapedParameters(parameters)
        
        let url = NSURL(string: urlString)!
        
        let request = NSMutableURLRequest(URL: url)
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            // println(NSString(data: data, encoding: NSUTF8StringEncoding))
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            
            if error != nil { // Handle error…
                completionHandler(result: nil, error: error)
            } else {
                OTMClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            }
        }
        
        task.resume()
        
        return task
    }
    
    func taskForPUTMethod(){
        
        let urlString = "https://api.parse.com/1/classes/StudentLocation/YmM2HdJOCK"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        
        request.HTTPMethod = "PUT"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"1612749455\", \"firstName\": \"John\", \"lastName\": \"Doe\",\"mapString\": \"Cupertino, CA\", \"mediaURL\": \"https://udacity.com\",\"latitude\": 37.322998, \"longitude\": -122.032182}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            println(NSString(data: data, encoding: NSUTF8StringEncoding))
        }
        task.resume()
    }

    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
    /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        
        if let parsedResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String : AnyObject] {
            
            if let errorMessage = parsedResult["status"] as? String {
                
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                
                return NSError(domain: "OTM Error", code: 1, userInfo: userInfo)
            }
        }
        
        return error
    }
    
    // MARK: - Shared Instance
    class func sharedInstance() -> OTMClient {
        
        struct Singleton {
            static var sharedInstance = OTMClient()
        }
        
        return Singleton.sharedInstance
    }
    
}