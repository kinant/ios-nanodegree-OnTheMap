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
    
    
    
    override func viewDidLoad() {
        distanceTabEnabled(false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        // create the navigation bar
        var navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 64))
        navBar.tintColor = .lightGrayColor()
        self.view.addSubview(navBar)
        
        var refreshButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        // var refreshBarButton = UIBarButtonItem(customView: refreshButton)
        
        // refreshBarButton.image = UIImage(named: "refresh")
        var refreshBarButton = UIBarButtonItem(image: UIImage(named: "refresh"), style: UIBarButtonItemStyle.Plain, target: self, action: "refresh")

        var postButton = UIBarButtonItem(image: UIImage(named: "placemark"), style: UIBarButtonItemStyle.Plain, target: self, action: "post")
        
        var logoutButton = UIBarButtonItem(image: UIImage(named: "logout"), style: UIBarButtonItemStyle.Plain, target: self, action: "logout")
        
        // create the navigation items
        var navItems = UINavigationItem(title: "On The Map")
        navItems.rightBarButtonItems = [refreshBarButton, postButton]
        navItems.leftBarButtonItem = logoutButton
        
        navBar.items = [navItems]
        
    }
    
    func distanceTabEnabled(enabled: Bool){
        let barViewControllers = self.viewControllers
        let distanceVC = barViewControllers![2] as! DistanceTableViewController
        distanceVC.tabBarItem.enabled = enabled
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
        
        postVC.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        postVC.preferredContentSize = self.view.frame.size
        postVC.delegate = mapVC
        
        if let popoverController = postVC.popoverPresentationController {
            popoverController.passthroughViews = [mapVC]
        }
        
        // check if user location already exists
        OTMClient.sharedInstance().userLocationExists { (exists, objectID, error) -> Void in
            
            if let userExistsError = error {
                OTMClient.sharedInstance().showAlert(self, title: "Error", message: userExistsError.localizedDescription, actions: ["OK"], completionHandler: { (choice) -> Void in
                    // do nothing
                })
            }
            
            if exists {
                
                OTMClient.sharedInstance().showAlert(self, title: "Location Exists!", message: "You have already submitted your location. Press OK to overwrite.", actions: ["OK","CANCEL"], completionHandler: { (choice) -> Void in
                        
                    if(choice == "OK"){
                        self.postVC.isUpdating = true
                        self.postVC.updatingObjectID = objectID
                        
                        if !(self.presentedViewController is UIAlertController) {
                            self.presentViewController(self.postVC, animated: true, completion: nil)
                        }
                    }
                })
            } else {
                // println("SHOULD TRY TO POST!!")
                self.postVC.isUpdating = false
                self.postVC.updatingObjectID = ""
                
                dispatch_async(dispatch_get_main_queue()){
                    if !(self.presentedViewController is UIAlertController) {
                        self.presentViewController(self.postVC, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func refresh()
    {
        let barViewControllers = self.viewControllers
        
        if(self.selectedViewController is StudentInfoTableViewController ){
            let tableVC = barViewControllers![1] as! StudentInfoTableViewController
            tableVC.refreshTable()
        }
        else {
            let mapVC = barViewControllers![0] as! MapViewController
            mapVC.refreshMap()
        }
    }
    
    func logout(){
        OTMClient.sharedInstance().logout(OTMClient.sharedInstance().signInMethod, completionHandler: { (success, error) -> Void in
            
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            
            if let logoutError = error {
                OTMClient.sharedInstance().showAlert(self, title: "Error", message: logoutError.localizedDescription, actions: ["OK"], completionHandler: { (choice) -> Void in
                    // do nothing
                })
            }
            
            if(success) {
                dispatch_async(dispatch_get_main_queue()){
                    let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
                    self.presentViewController(loginVC, animated: true, completion: nil)
                }
            }
        })
    }
}