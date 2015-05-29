//
//  ViewController.swift
//  OnTheMap
//
//  Created by Kinan Turjman on 5/8/15.
//  Copyright (c) 2015 Kinan Turjman. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {

    
    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        OTMClient.sharedInstance().taskForDelete()
        
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            OTMClient.sharedInstance().FBaccessToken = FBSDKAccessToken.currentAccessToken().tokenString
            login(OTMClient.OTMAPIs.Facebook)
        }
        else
        {
            let loginView : FBSDKLoginButton = FBSDKLoginButton()
            self.view.addSubview(loginView)
            loginView.center = self.view.center
            loginView.frame.origin.y = self.view.frame.height - 50
            loginView.readPermissions = ["public_profile", "email", "user_friends"]
            loginView.delegate = self
        }
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            OTMClient.sharedInstance().FBaccessToken = FBSDKAccessToken.currentAccessToken().tokenString
            login(OTMClient.OTMAPIs.Facebook)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        println("User Logged Out")
    }
    
    func login(api: OTMClient.OTMAPIs){
        
        SwiftSpinner.show("Loging in", description: "", animated: true)
        
        OTMClient.sharedInstance().login(self, api:api, username: usernameTextfield.text, password: passwordTextfield.text, completionHandler: { (success, errorString) -> Void in
            
            println("Finished trying to log in!")
            
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    SwiftSpinner.hide()
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("tabBarController") as! UITabBarController
                    self.presentViewController(controller, animated: true, completion: nil)
                })
            } else {
                dispatch_async(dispatch_get_main_queue()){
                    self.statusLabel.text = errorString
                    self.statusLabel.hidden = false
                    
                    SwiftSpinner.show("Failed to log in ...", description: errorString!, animated: false)
                    
                    delay(2.0){
                        // SwiftSpinner.hide()
                    }
                    // OTMClient.sharedInstance().showAlert(self, title: "Error", message: errorString!, actions: ["OK"], completionHandler: { (choice) -> Void in
                        
                    //})
                }
            }
        })
    }
    
    @IBAction func loginButton(sender: AnyObject) {
        login(OTMClient.OTMAPIs.Udacity)
    }
}

