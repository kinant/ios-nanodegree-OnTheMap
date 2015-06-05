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
        
        // OTMClient.sharedInstance().taskForDelete()
        
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
        
        let tapScreen = UITapGestureRecognizer(target: self, action: "hideKeyboard")
        self.view.addGestureRecognizer(tapScreen)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        self.unsubscribeFromKeyboardNotifications()
    }
    
    func hideKeyboard(){
        usernameTextfield.resignFirstResponder()
        passwordTextfield.resignFirstResponder()
    }
    
    // =========================================================================
    // MARK: Keyboard Related Functions
    // BELOW ARE ALL THE FUNCTIONS THAT ARE RELATED TO THE KEYBOARD
    // =========================================================================
    
    // subscribe to keyboard notifications
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:"    , name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:"    , name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // unsubscribe to keyboard notifications
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // function to move the view and its contents up when the keyboard is shown
    func keyboardWillShow(notification: NSNotification) {
        self.view.bounds.origin.y += getKeyboardHeight(notification)
    }
    
    // function that moves the view and its contents back down when the keyboard is hidden
    func keyboardWillHide(notification: NSNotification) {
        self.view.bounds.origin.y -= getKeyboardHeight(notification)
    }
    
    // function that gets the height of the keyboard
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
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
        //println("User Logged Out")
    }
    
    func login(api: OTMClient.OTMAPIs){
        
        SwiftSpinner.show("Logging in", description: "", animated: true)
        
        activityIndicatorEnabled(true)
        
        OTMClient.sharedInstance().login(self, api:api, username: usernameTextfield.text, password: passwordTextfield.text, completionHandler: { (success, error) -> Void in
            
            //println("Finished trying to log in!")
            
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    
                    SwiftSpinner.hide()
                    
                    activityIndicatorEnabled(false)
                    
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("tabBarController") as! UITabBarController
                    self.presentViewController(controller, animated: true, completion: nil)
                })
            } else {
                dispatch_async(dispatch_get_main_queue()){
                    self.statusLabel.text = error!.localizedDescription
                    self.statusLabel.hidden = false
                    
                    SwiftSpinner.show("Failed to log in ...", description: error!.localizedDescription, animated: false)
                    self.hideKeyboard()
                }
            }
        })
    }
    
    @IBAction func signUp(sender: AnyObject) {
        OTMClient.sharedInstance().browseToURL("https://www.udacity.com/account/auth#!/signup")
    }
    
    @IBAction func loginButton(sender: AnyObject) {
        login(OTMClient.OTMAPIs.Udacity)
    }
}

