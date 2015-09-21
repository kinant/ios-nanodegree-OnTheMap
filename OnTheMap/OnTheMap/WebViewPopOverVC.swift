//
//  WebViewPopOverVC.swift
//  OnTheMap
//
//  Created by Kinan Turjman on 5/12/15.
//  Copyright (c) 2015 Kinan Turjman. All rights reserved.
//

import UIKit

/* Popover View Controller to display a custom web browser that the user can use to browse for the URL 
 * Followed the following website for help:
 * - http://www.appcoda.com/webkit-framework-intro/
*/

class WebViewPopOverVC: UIViewController, UITextFieldDelegate, UIWebViewDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var webView: UIWebView! // webview outlet
    @IBOutlet weak var urlField: UITextField! // url textfield outlet
    @IBOutlet weak var backButton: UIBarButtonItem! // back button outlet
    @IBOutlet weak var forwardButton: UIBarButtonItem! // forward button outlet
    @IBOutlet weak var useButton: UIBarButtonItem! // use button outlet
    @IBOutlet weak var progressBar: UIProgressView! // progress bar outlet (for "showing" progress)
    
    // MARK: Properties
    var delegate: PostLocationPopOverVC? = nil
    
    // these are used for the progress bar
    // from: http://stackoverflow.com/questions/28147096/progressbar-webview-in-swift
    var theBool: Bool = false
    var myTimer = NSTimer()
    
    // flag for when loading has started
    var didStartLoad = false
    
    // MARK: Overriden View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // disable the back and forward buttons
        backButton.enabled = false
        forwardButton.enabled = false
        
        webView.delegate = self
        
        // load google initially
        loadRequest("www.google.com")
    }
    
    // MARK: Textfield Delegate Functions
    /* For when the textfield returns */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        urlField.resignFirstResponder()
        
        // escape the url from the url text field
        var urlEscapedString = urlField.text!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
        // load the request
        loadRequest(urlEscapedString!)
        
        return false
    }
    
    // MARK: WebVuew Delegate Functions
    /* delegate function for then the webview starts to load */
    func webViewDidStartLoad(webView: UIWebView) {
        
        // check that did not previously start loading
        if !didStartLoad {
            self.didStartLoad = true
            
            // show the progress bar and set the variables to make it "work"
            // from: http://stackoverflow.com/questions/28147096/progressbar-webview-in-swift
            self.progressBar.hidden = false
            self.progressBar.progress = 0.0
            self.theBool = false
            self.myTimer = NSTimer.scheduledTimerWithTimeInterval(0.01667, target: self, selector: "timerCallback", userInfo: nil, repeats: true)
        }
        
        // disable the use button
        self.useButton.enabled = false
    }
    
    /* delegate function for then the webview finishes to load */
    func webViewDidFinishLoad(webView: UIWebView) {
        
        // set the variables for handling the progress bar
        self.theBool = true
        self.didStartLoad = false
        
        // enable/disable the relevant buttons
        backButton.enabled = webView.canGoBack
        forwardButton.enabled = webView.canGoForward
        useButton.enabled = true
        
        // set the url textfield text to the loaded url
        urlField.text = webView.request!.URL!.description
    }
    
    /* Handles a failure to load the requested URL*/
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        
        // first show an alert, one of the options is to google what the user inputed
        OTMClient.sharedInstance().showAlert(self, title: "Error", message: error!.localizedDescription, actions: ["OK", "Google it!"]) { (choice) -> Void in
            
            // check if the user chose to google his request
            if(choice == "Google it!"){
                
                // get the search string by removing the http or https prefixes
                var searchString = self.urlField.text!.stringByReplacingOccurrencesOfString("http://", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                
                searchString = searchString.stringByReplacingOccurrencesOfString("https://", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                
                // espcape the search string
                var escapedSearchString = searchString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
                
                // create the google search url
                var googleStringURL = "www.google.com/search?q=\(escapedSearchString!)"
                
                // load the search request
                self.loadRequest(googleStringURL)
            }
        }
    }
    
    // MARK: OTHER FUNCTIONS
    /* loads a requested url into the webview */
    func loadRequest(urlString: String){
        
        // check if the url has the prefix, if not, we will add it
        let prefix = (urlString.hasPrefix("http://") || urlString.hasPrefix("https://") ) ? "" : "http://"
        
        // make the request
        webView.loadRequest(NSURLRequest(URL: NSURL(string: prefix + urlString)!))
    }
    
    /* function for handling the progress bar
     * - from: http://stackoverflow.com/questions/28147096/progressbar-webview-in-swift
    */
    func timerCallback() {
        if self.theBool {
            if self.progressBar.progress >= 1 {
                self.progressBar.hidden = true
                self.myTimer.invalidate()
            } else {
                self.progressBar.progress += 0.1
            }
        } else {
            self.progressBar.progress += 0.05
            if self.progressBar.progress >= 0.95 {
                self.progressBar.progress = 0.95
            }
        }
    }
    
    // MARK: IBAction Functions for Buttons
    
    /* handle back button being pressed */
    @IBAction func backButtonTouch(sender: AnyObject) {
        webView.goBack()
    }
    
    /* handle forward button being pressed */
    @IBAction func forwardButtonTouch(sender: AnyObject) {
        webView.goForward()
    }

    /* handle stop button being pressed */
    @IBAction func stopButtonTouch(sender: AnyObject) {
        webView.stopLoading()
    }
    
    /* handle refresh button being pressed */
    @IBAction func refreshButtonTouch(sender: AnyObject) {
        // reload the website
        loadRequest(webView.request!.URL!.description)
    }

    /* handle the USE button being pressed */
    @IBAction func useLink(sender: AnyObject) {
        
        // the delegate (PostLocation View Controller) will set the URL in its view
        delegate?.setURL(webView.request!.URL!.description)
        
        // dismiss the popup web browser
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /* close the browser */
    @IBAction func cancelBrowse(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
