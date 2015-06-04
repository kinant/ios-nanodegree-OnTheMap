//
//  WebViewPopOverVC.swift
//  OnTheMap
//
//  Created by Kinan Turjman on 5/12/15.
//  Copyright (c) 2015 Kinan Turjman. All rights reserved.
//

import UIKit

class WebViewPopOverVC: UIViewController, UITextFieldDelegate, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var urlField: UITextField!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    
    @IBOutlet weak var useButton: UIBarButtonItem!
    
    @IBOutlet weak var progressBar: UIProgressView!
    var delegate: PostLocationPopOverVC? = nil
    
    var theBool: Bool = false
    var myTimer = NSTimer()
    var didStartLoad = false
    
    var isPosting = false
    var loadingURL = "www.google.com"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        backButton.enabled = false
        forwardButton.enabled = false
        
        webView.delegate = self
        
        loadRequest(loadingURL)
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        urlField.resignFirstResponder()
        
        var urlEscapedString = urlField.text.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        loadRequest(urlEscapedString!)
        
        return false
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        if !didStartLoad {
            self.didStartLoad = true
            self.progressBar.hidden = false
            self.progressBar.progress = 0.0
            self.theBool = false
            self.myTimer = NSTimer.scheduledTimerWithTimeInterval(0.01667, target: self, selector: "timerCallback", userInfo: nil, repeats: true)
        }
        self.useButton.enabled = false
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.theBool = true
        self.didStartLoad = false
        backButton.enabled = webView.canGoBack
        forwardButton.enabled = webView.canGoForward
        useButton.enabled = true
        urlField.text = webView.request!.URL!.description
    }
    
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
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        
        OTMClient.sharedInstance().showAlert(self, title: "Error", message: error.localizedDescription, actions: ["OK", "Google it!"]) { (choice) -> Void in
            
            var searchString = self.urlField.text.stringByReplacingOccurrencesOfString("http://", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            searchString = searchString.stringByReplacingOccurrencesOfString("https://", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            var escapedSearchString = searchString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            if(choice == "Google it!"){
                var googleStringURL = "www.google.com/search?q=\(escapedSearchString!)"
                self.loadRequest(googleStringURL)
            }
        }
    }
    
    func loadRequest(urlString: String){
        var prefix = (urlString.hasPrefix("http://") || urlString.hasPrefix("https://") ) ? "" : "http://"
        webView.loadRequest(NSURLRequest(URL: NSURL(string: prefix + urlString)!))
    }
    
    @IBAction func backButtonTouch(sender: AnyObject) {
        webView.goBack()
    }

    @IBAction func forwardButtonTouch(sender: AnyObject) {
        webView.goForward()
    }

    @IBAction func stopButtonTouch(sender: AnyObject) {
        webView.stopLoading()
    }
    
    @IBAction func refreshButtonTouch(sender: AnyObject) {
        loadRequest(webView.request!.URL!.description)
    }
    
    @IBAction func useLink(sender: AnyObject) {
        delegate?.setURL(webView.request!.URL!.description)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
