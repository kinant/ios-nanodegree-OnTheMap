//
//  ViewController.swift
//  OnTheMap
//
//  Created by Kinan Turjman on 5/8/15.
//  Copyright (c) 2015 Kinan Turjman. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    
    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButton(sender: AnyObject) {
        OTMClient.sharedInstance().udacityLogin(self,username: usernameTextfield.text, password: passwordTextfield.text, completionHandler: { (success, errorString) -> Void in
        
            if success {
                println("successfully logged in!")
                println(OTMClient.sharedInstance().sessionID)
            } else {
                dispatch_async(dispatch_get_main_queue()){
                    self.statusLabel.text = errorString
                    self.statusLabel.hidden = false
                }
            }
        })
    }
}

