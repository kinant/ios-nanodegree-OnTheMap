//
//  TabBarVC.swift
//  OnTheMap
//
//  Created by KT on 6/3/15.
//  Copyright (c) 2015 Kinan Turjman. All rights reserved.
//

import Foundation

class TabBarVC: UITabBarController, UIPopoverPresentationControllerDelegate {
    
    let postVC = PostLocationPopOverVC(nibName: "PostLocationPopOverVC", bundle: nil)
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        // create the navigation bar
        var navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 64))
        navBar.tintColor = .lightGrayColor()
        self.view.addSubview(navBar)
        
        // create the buttons
        var refreshButton = UIBarButtonItem(title: "R", style: UIBarButtonItemStyle.Plain, target: self, action: "refresh")
        var postButton = UIBarButtonItem(title: "P", style: UIBarButtonItemStyle.Plain, target: self, action: "post")
        var logoutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logout")
        
        // create the navigation items
        var navItems = UINavigationItem(title: "On The Map")
        navItems.rightBarButtonItems = [refreshButton, postButton]
        navItems.leftBarButtonItem = logoutButton
        
        navBar.items = [navItems]
        
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        return .None
    }
    
    func post()
    {
        let barViewControllers = self.viewControllers
        let mapVC = barViewControllers![0] as! MapViewController
        
        // if at tab bar, switch selected view controller
        if(self.selectedViewController is StudentInfoTableViewController ){
            self.selectedViewController = mapVC
        }
        
        mapVC.test()
        
        postVC.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        postVC.preferredContentSize = self.view.frame.size
        
        postVC.delegate = mapVC
        
        // check if user location already exists
        OTMClient.sharedInstance().userLocationExists { (exists, objectID) -> Void in
            
            if exists {
                
                if self.presentedViewController == nil {
                    OTMClient.sharedInstance().showAlert(self, title: "Location Exists!", message: "You have already submitted your location. Press OK to overwrite.", actions: ["OK","CANCEL"], completionHandler: { (choice) -> Void in
                        
                        if(choice == "OK"){
                            self.postVC.isUpdating = true
                            self.postVC.updatingObjectID = objectID
                            self.presentViewController(self.postVC, animated: true, completion: nil)
                        }
                    })
                }
            } else {
                // println("SHOULD TRY TO POST!!")
                self.postVC.isUpdating = false
                self.postVC.updatingObjectID = ""
                
                dispatch_async(dispatch_get_main_queue()){
                    self.presentViewController(self.postVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    func refresh()
    {
        // println("refresh pressed!")
    }
    
    func logout(){
        OTMClient.sharedInstance().logout(OTMClient.sharedInstance().signInMethod, completionHandler: { (success) -> Void in
            
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            
            if(success) {
                dispatch_async(dispatch_get_main_queue()){
                    let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
                    self.presentViewController(loginVC, animated: true, completion: nil)
                }
            }
        })
    }
}