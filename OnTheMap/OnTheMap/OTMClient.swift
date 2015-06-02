//
//  OTMClient.swift
//  OnTheMap
//
//  Created by Kinan Turjman on 5/8/15.
//  Copyright (c) 2015 Kinan Turjman. All rights reserved.
//

// println(NSString(data: newData, encoding: NSUTF8StringEncoding))

import Foundation

class OTMClient: NSObject {

    var session: NSURLSession
    var userID: String? = nil
    var sessionID: String? = nil
    var currentLoadCount = 0
    var student: OTMStudentInformation? = nil
    var FBaccessToken: String? = nil
    var signInMethod: OTMAPIs!
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    func taskForPOSTandPUTDataMethod(api: OTMAPIs, baseURL: String, method: String, parameters: [String : AnyObject], httpBody: String, updatingID: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        var urlString:String!
        
        switch api {
        
        case .Parse:
            urlString = baseURL + "/" + updatingID
        case .Udacity:
            urlString = baseURL + method
        default:
            println()
        }
        
        let url = NSURL(string: urlString)!
        
        let request = NSMutableURLRequest(URL: url)
        
        if(updatingID != "" ) {
            request.HTTPMethod = "PUT"
        } else {
            request.HTTPMethod = "POST"
        }
        
        request.HTTPBody = httpBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        switch api {
            
        case .Parse:
            request.addValue(OTMClient.ParseAPIConstants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(OTMClient.ParseAPIConstants.RESTKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        case .Udacity:
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        default:
            println()
        }
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            var newData = data
            
            if error != nil { // Handle error…
                let connectionError = NSError(domain: "Connection Error", code: error.code, userInfo: error.userInfo)
                completionHandler(result: nil, error: connectionError)
            } else {
                
                if(api == OTMAPIs.Udacity)
                {
                    newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
                }
                
                if let serverError = OTMClient.returnStatusError(api, data: newData) {
                    completionHandler(result: nil, error: serverError)
                } else {
                    OTMClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
                }
            }
        }
        
        task.resume()
        
        return task
    }

    func taskForGETDataMethod(api: OTMAPIs, baseURL: String, method: String, parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let urlString = baseURL + method + OTMClient.escapedParameters(parameters)
        
        println(urlString)
        
        let url = NSURL(string: urlString)!
        
        let request = NSMutableURLRequest(URL: url)
        
        switch api {
            
        case .Parse:
            request.addValue(OTMClient.ParseAPIConstants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(OTMClient.ParseAPIConstants.RESTKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
            
        case .Udacity:
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        default:
            println()
        }
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            var newData = data
            
            if(api == OTMAPIs.Udacity)
            {
                newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                
            }
            
            if error != nil {
                let connectionError = NSError(domain: "Connection Error", code: error.code, userInfo: error.userInfo)
                completionHandler(result: nil, error: connectionError)
            } else {
                
                if(api == OTMAPIs.Udacity)
                {
                    newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
                }
                
                if let serverError = OTMClient.returnStatusError(api, data: newData) {
                    completionHandler(result: nil, error: serverError)
                } else {
                    OTMClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
                }
            }
        }
        
        task.resume()
        
        return task
    }
        
    func taskForDelete(api: OTMAPIs, baseURL: String, method: String, parameters: [String : AnyObject], completionHandler: (success: Bool, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let urlString = baseURL + method
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        
        request.HTTPMethod = "DELETE"
        
        if(api == OTMAPIs.Udacity){
            var xsrfCookie: NSHTTPCookie? = nil
            let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
            for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
                if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
            }
            if let xsrfCookie = xsrfCookie {
                request.addValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-Token")
            }
        } else if api == OTMAPIs.Parse {
            request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        }
            
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                completionHandler(success: false, error: error)
            }
            completionHandler(success: true, error: nil)
        }
        task.resume()
        
        return task
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
    
    func showAlert(view: UIViewController, title: String, message: String, actions: [String] , completionHandler: (choice: String?) -> Void ){
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        for action in actions {
            alert.addAction(UIAlertAction(title: action, style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in
                completionHandler(choice: action)
            }))
        }
        
        dispatch_async(dispatch_get_main_queue()){
            view.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    class func returnStatusError(api: OTMAPIs, data: NSData?) -> NSError? {
        var newError:NSError!
        
        println(NSString(data: data!, encoding: NSUTF8StringEncoding))
        
        if let parsedResult: AnyObject = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) {
            
            if let errorMessage = parsedResult.valueForKey("error") as? String {
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                
                if (api == OTMAPIs.Parse){
                    if let parseStatusCode = parsedResult.valueForKey("code") as? Int {
                        newError = NSError(domain: "OTM Parse API Error", code: parseStatusCode, userInfo: userInfo)
                    } else {
                        newError = NSError(domain: "OTM Parse API Error", code: 0, userInfo: userInfo)
                    }
                } else {
                    if let udacityStatusCode = parsedResult.valueForKey("status") as? Int {
                        newError = NSError(domain: "OTM Udacity API Error", code: udacityStatusCode, userInfo: userInfo)
                    }
                }
            }
        }
        
        return newError
    }
    
    // MARK: - Shared Instance
    class func sharedInstance() -> OTMClient {
        
        struct Singleton {
            static var sharedInstance = OTMClient()
        }
        
        return Singleton.sharedInstance
    }
    
}