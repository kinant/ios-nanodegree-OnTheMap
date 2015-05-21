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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.enabled = false
        forwardButton.enabled = false
        
        webView.delegate = self
        
        let url = NSURL(string:"http://www.google.com")
        let request = NSURLRequest(URL:url!)
        webView.loadRequest(request)
        
        // Do any additional setup after loading the view.
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        urlField.resignFirstResponder()
        webView.loadRequest(NSURLRequest(URL: NSURL(string: urlField.text)!))
        return false
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if(range.location == 6 && range.length == 1) {
            return false
        }
        else {
            return true
        }
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
        println("finish load")
        self.theBool = true
        self.didStartLoad = false
        backButton.enabled = webView.canGoBack
        forwardButton.enabled = webView.canGoForward
        useButton.enabled = true
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        let request = NSURLRequest(URL:webView.request!.URL!)
        webView.loadRequest(request)
    }
    
    @IBAction func useLink(sender: AnyObject) {
        delegate?.setURL(webView.request!.URL!.host!)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
