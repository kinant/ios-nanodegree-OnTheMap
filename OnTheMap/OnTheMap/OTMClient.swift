//
//  OTMClient.swift
//  OnTheMap
//
//  Created by Kinan Turjman on 5/8/15.
//  Copyright (c) 2015 Kinan Turjman. All rights reserved.
//

// println(NSString(data: newData, encoding: NSUTF8StringEncoding))

import Foundation

// This class handles all the apps networking plus contains some utility functions.
class OTMClient: NSObject {

    // MARK: Properties
    var session: NSURLSession // for storing the session
    var userID: String? = nil // for storing user's Udacity ID Key
    var sessionID: String? = nil // for storing user's Udacity session ID
    var student: OTMStudentInformation? = nil // for storing the students information
    var FBaccessToken: String? = nil // for storing FB access token
    
    // MARK: init
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: PUT and POST
    // function for PUT or POST network data requests
    func taskForPOSTandPUTDataMethod(api: OTMAPIs, baseURL: String, method: String, parameters: [String : AnyObject], httpBody: String, updatingID: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        var urlString:String!
        
        /* 1. check which api we are working with (udacity or parse) and set the url string */
        switch api {
        
        case .Parse:
            urlString = baseURL + "/" + updatingID
        case .Udacity:
            urlString = baseURL + method
        default:
            print("")
        }
        
        /* 2/3. Build the URL and configure the request */
        let url = NSURL(string: urlString)!
        
        let request = NSMutableURLRequest(URL: url)
        
        if(updatingID != "" ) {
            request.HTTPMethod = "PUT"
        } else {
            request.HTTPMethod = "POST"
        }
        
        request.HTTPBody = httpBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        // check api again and add appropiate values
        switch api {
            
        case .Parse:
            request.addValue(OTMClient.ParseAPIConstants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(OTMClient.ParseAPIConstants.RESTKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        case .Udacity:
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        default:
            print("")
        }
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            var newData = data
            
            /* 5. Handle data */
            
            // handle errors
            if error != nil {
                // create a connection error (most likely scenario)
                let connectionError = NSError(domain: "Connection Error", code: error!.code, userInfo: error!.userInfo)
                completionHandler(result: nil, error: connectionError)
            } else {
                
                // if udacity api is used, subset the response data
                if(api == OTMAPIs.Udacity)
                {
                    newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
                }
                
                // check response for any server-side errors
                if let serverError = OTMClient.returnStatusError(api, data: newData) {
                    completionHandler(result: nil, error: serverError)
                } else {
                    
                    /* 6. Parse data: if no server-side or client-side errors, then proceed to parse data */
                    OTMClient.parseJSONWithCompletionHandler(newData!, completionHandler: completionHandler)
                }
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }

    // MARK: GET
    // function for GET network data requests
    func taskForGETDataMethod(api: OTMAPIs, baseURL: String, method: String, parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1/2/3. Build the URL and configure the request */
        let urlString = baseURL + method + OTMClient.escapedParameters(parameters)
        
        let url = NSURL(string: urlString)!
        
        let request = NSMutableURLRequest(URL: url)
        
        // check api again and add appropiate values
        switch api {
            
        case .Parse:
            request.addValue(OTMClient.ParseAPIConstants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(OTMClient.ParseAPIConstants.RESTKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
            
        case .Udacity:
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        default:
            print("")
        }
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            var newData = data
            
            /* 5. Handle data */
            
            // handle errors
            if error != nil {
                // create a connection error (most likely scenario)
                let connectionError = NSError(domain: "Connection Error", code: error!.code, userInfo: error!.userInfo)
                completionHandler(result: nil, error: connectionError)
            } else {
                // if udacity api is used, subset the response data
                if(api == OTMAPIs.Udacity)
                {
                    newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
                }
                
                // check response for any server-side errors
                if let serverError = OTMClient.returnStatusError(api, data: newData) {
                    completionHandler(result: nil, error: serverError)
                } else {
                    /* 6. Parse data: if no server-side or client-side errors, then proceed to parse data */
                    OTMClient.parseJSONWithCompletionHandler(newData!, completionHandler: completionHandler)
                }
            }
        }
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    // MARK: DELETE
    func taskForDelete(api: OTMAPIs, baseURL: String, method: String, parameters: [String : AnyObject], completionHandler: (success: Bool, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1/2/3. Build the URL and configure the request */
        let urlString = baseURL + method
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        
        request.HTTPMethod = "DELETE"
        
        if(api == OTMAPIs.Udacity){
            var xsrfCookie: NSHTTPCookie? = nil
            let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
            for cookie in sharedCookieStorage.cookies! {
                if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
            }
            if let xsrfCookie = xsrfCookie {
                request.addValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-Token")
            }
        } else if api == OTMAPIs.Parse {
            request.addValue(OTMClient.ParseAPIConstants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(OTMClient.ParseAPIConstants.RESTKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        }
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            var newData = data
            
            /* 5. Handle data */
            
            // handle errors
            if error != nil {
                // create a connection error (most likely scenario)
                let connectionError = NSError(domain: "Connection Error", code: error!.code, userInfo: error!.userInfo)
                completionHandler(success: false, error: connectionError)
            } else {
                // if udacity api is used, subset the response data
                if(api == OTMAPIs.Udacity)
                {
                    newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
                }
                
                // check response for any server-side errors
                if let serverError = OTMClient.returnStatusError(api, data: newData) {
                    print(serverError.localizedDescription)
                    completionHandler(success: false, error: serverError)
                } else {
                    /* 6. if no server-side or client-side errors, then deletion was successful, continue with completion handler */
                    completionHandler(success: true, error: nil)
                }
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    // MARK: OTHER FUNCTIONS - HELPER FUNCTIONS
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
        }
        
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
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    /* Helper function: The requests can return data even if there were errors server side, from either the Parse or the Udacity APIs
    this function checks the data that was sent in the response for such server errors (status codes, etc.)*/
    class func returnStatusError(api: OTMAPIs, data: NSData?) -> NSError? {
        var newError:NSError!
        
        // parse the data
        if let parsedResult: AnyObject = try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) {
            
            // check if the parsed results has an error object
            if let errorMessage = parsedResult.valueForKey("error") as? String {
                
                // set the error description
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                
                // check which API the error corresponds to and initialize the error
                if (api == OTMAPIs.Parse){
                    
                    // some Parse API errors have a code, others don't, so we check
                    if let parseStatusCode = parsedResult.valueForKey("code") as? Int {
                        newError = NSError(domain: "OTM Parse API Error", code: parseStatusCode, userInfo: userInfo)
                    } else {
                        newError = NSError(domain: "OTM Parse API Error", code: 0, userInfo: userInfo)
                    }
                } else {
                    // check for the udacity status code
                    if let udacityStatusCode = parsedResult.valueForKey("status") as? Int {
                        newError = NSError(domain: "OTM Udacity API Error", code: udacityStatusCode, userInfo: userInfo)
                    }
                }
            }
        }
        
        // return the newly created error (if no error found, will return nil)
        return newError
    }
    
    /* Helper function: Display an alert. The entire app uses this same function for alerts, which is why it has
       a completion handler as a closure */
    func showAlert(view: UIViewController, title: String, message: String, actions: [String] , completionHandler: ((choice: String?) -> Void )?){
        
        // make sure no alert is already being presented
        if !(view.presentedViewController is UIAlertController) {
            
            // create the alert
            var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
            // iterate over every action to create its option in the alert
            for action in actions {
                alert.addAction(UIAlertAction(title: action, style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in
                    
                    // call completion handler if it exists
                    if let handler = completionHandler {
                        handler(choice: action)
                    }
                }))
            }
        
            // present the alert
            dispatch_async(dispatch_get_main_queue()){
                view.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    /* Helper function: Opens the user's default brower and browses to the url specified by urlString  parameter */
    func browseToURL(urlString: String){
        var url = NSURL(string: urlString)
        UIApplication.sharedApplication().openURL(url!)
    }
    
    // MARK: - Shared Instance
    class func sharedInstance() -> OTMClient {
        
        struct Singleton {
            static var sharedInstance = OTMClient()
        }
        
        return Singleton.sharedInstance
    }
    
}