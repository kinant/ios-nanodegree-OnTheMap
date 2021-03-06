//
//  ViewController.swift
//  OnTheMap
//
//  Created by Kinan Turjman on 5/8/15.
//  Copyright (c) 2015 Kinan Turjman. All rights reserved.
//

import UIKit

/* View Controller for the Log in View */
class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {

    // MARK: Outlets
    @IBOutlet weak var usernameTextfield: UITextField! // username textfield outlet
    @IBOutlet weak var passwordTextfield: UITextField! // password textfield outlet
    @IBOutlet weak var statusLabel: UILabel! // outlet for the status label
    
    var viewMoved = false
    
    // MARK: Overriden View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // gesture recognizer for when the user taps the screen (to dismiss keyboard)
        let tapScreen = UITapGestureRecognizer(target: self, action: "hideKeyboard")
        self.view.addGestureRecognizer(tapScreen)
    }
    
    override func viewDidAppear(animated: Bool) {
        // facebook login, check if already have access token
        // FROM: http://www.brianjcoleman.com/tutorial-how-to-use-login-in-facebook-sdk-4-0-for-swift/
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            // if token exists, then we show the spinner and log the user in
            SwiftSpinner.show("Facebook Access Token Found!", description: "", animated: true)
            OTMClient.sharedInstance().FBaccessToken = FBSDKAccessToken.currentAccessToken().tokenString
            
            delay(1.0){
                self.login(OTMClient.OTMAPIs.Facebook)
            }
        }
        else
        {
            // no access token, add button to view
            let loginView : FBSDKLoginButton = FBSDKLoginButton()
            self.view.addSubview(loginView)
            loginView.center = self.view.center
            loginView.frame.origin.y = self.view.frame.height - 50
            loginView.readPermissions = ["public_profile", "email", "user_friends"]
            loginView.delegate = self
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        self.unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: Keyboard Related Functions
    
    /* Hides the keyboard */
    func hideKeyboard(){
        usernameTextfield.resignFirstResponder()
        passwordTextfield.resignFirstResponder()
    }
    
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
        if !viewMoved {
            self.view.bounds.origin.y += getKeyboardHeight(notification)
            viewMoved = true
        }
    }
    
    // function that moves the view and its contents back down when the keyboard is hidden
    func keyboardWillHide(notification: NSNotification) {
        if viewMoved {
            self.view.bounds.origin.y -= getKeyboardHeight(notification)
            viewMoved = false
        }
    }
    
    // function that gets the height of the keyboard
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    // MARK: FacebookSDK Functions
    // Facebook SDK Log In
    // From: http://www.brianjcoleman.com/tutorial-how-to-use-login-in-facebook-sdk-4-0-for-swift/
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        // check for errors
        if ((error) != nil)
        {
            // handle error
            OTMClient.sharedInstance().showAlert(self, title: "Facebook Error", message: error.localizedDescription, actions: ["OK"], completionHandler: nil)
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // no error, facebook log in successfull, set the access token
            OTMClient.sharedInstance().FBaccessToken = FBSDKAccessToken.currentAccessToken().tokenString
            
            // proceed to login into app with facebook
            login(OTMClient.OTMAPIs.Facebook)
        }
    }
    
    /* must be present for delegate */
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        // do nothing
    }
    
    // MARK: LOG IN FUNCTIONS
    /* handles the apps login with facebook or udacity api */
    func login(api: OTMClient.OTMAPIs){
        
        // hide the keyboard if present
        self.hideKeyboard()
        
        // show the spinner
        SwiftSpinner.show("Logging in", description: "", animated: true)
        
        // show activity indicator
        activityIndicatorEnabled(true)
        
        // proceed to attempt to login
        OTMClient.sharedInstance().login(self, api:api, username: usernameTextfield.text!, password: passwordTextfield.text!, completionHandler: { (success, error) -> Void in
            
            // if successfull ->
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    
                    // hide spinner and activity indicator
                    SwiftSpinner.hide()
                    activityIndicatorEnabled(false)
                    
                    // instantiate and present the tab bar controller
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("tabBarController") as! UITabBarController
                    self.presentViewController(controller, animated: true, completion: nil)
                })
            } else {
                // if there was an error, change the status label
                dispatch_async(dispatch_get_main_queue()){
                    self.statusLabel.text = error!.localizedDescription
                    self.statusLabel.hidden = false
                    
                    // present error in spinner
                    SwiftSpinner.show("Failed to log in ...", description: error!.localizedDescription, animated: false)
                }
            }
        })
    }
    
    // MARK: IBAction Functions
    /* handle tapping the sign up button */
    @IBAction func signUp(sender: AnyObject) {
        
        // take user to udacity sign up page
        OTMClient.sharedInstance().browseToURL(OTMClient.UdacityConstants.SingUpURL)
    }
    
    /* handles tapping of login button*/
    @IBAction func loginButton(sender: AnyObject) {
        // log in using udacity API (no facebook)
        login(OTMClient.OTMAPIs.Udacity)
    }
}

