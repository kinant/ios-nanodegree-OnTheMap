//
//  WebViewPopOverVC.swift
//  OnTheMap
//
//  Created by Kinan Turjman on 5/12/15.
//  Copyright (c) 2015 Kinan Turjman. All rights reserved.
//

import UIKit

class WebViewPopOverVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var urlField: UITextField!
    
    var delegate: PostLocationPopOverVC? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func useLink(sender: AnyObject) {
        
        println(webView.request!.URL!.absoluteString!)
        println(webView.request!.URL!.host!)
        // println(webView.request?.URL?.description)
        delegate?.setURL(webView.request!.URL!.host!)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
