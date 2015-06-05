//
//  TabBarVC.swift
//  OnTheMap
//
//  Created by KT on 6/3/15.
//  Copyright (c) 2015 Kinan Turjman. All rights reserved.
//

import Foundation

/* Custom tab bar controller for apps tab bar */
class TabBarVC: UITabBarController, UIPopoverPresentationControllerDelegate {
    
    // MARK: Properties
    let postVC = PostLocationPopOverVC(nibName: "PostLocationPopOverVC", bundle: nil) // load the post location nib
    
    // to store the tab bar view controllers
    var mapVC: MapViewController!
    var studentTableVC: StudentInfoTableViewController!
    var distanceTableVC: DistanceTableViewController!
    
    // MARK: Overriden View Functions
    override func viewDidLoad() {
        
        // get all the view controllers
        let barViewControllers = self.viewControllers!
        
        // set the view controllers
        mapVC = barViewControllers[TabBarViewControllers.MapVC.rawValue] as! MapViewController
        studentTableVC = barViewControllers[TabBarViewControllers.TableVC.rawValue] as! StudentInfoTableViewController
        distanceTableVC = barViewControllers[TabBarViewControllers.DistanceVC.rawValue] as! DistanceTableViewController
        
        // disable the distance tab bar item
        distanceTabEnabled(false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        // create the navigation bar
        // help from: https://gist.github.com/thecanalboy/106a0b9b8a7da6d7713c
        var navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 64))
        navBar.tintColor = .lightGrayColor()
        self.view.addSubview(navBar)
        
        var refreshButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        var refreshBarButton = UIBarButtonItem(image: UIImage(named: "refresh"), style: UIBarButtonItemStyle.Plain, target: self, action: "refresh")

        var postButton = UIBarButtonItem(image: UIImage(named: "placemark"), style: UIBarButtonItemStyle.Plain, target: self, action: "post")
        
        var logoutButton = UIBarButtonItem(image: UIImage(named: "logout"), style: UIBarButtonItemStyle.Plain, target: self, action: "logout")
        
        // create the navigation items
        var navItems = UINavigationItem(title: "On The Map")
        navItems.rightBarButtonItems = [refreshBarButton, postButton]
        navItems.leftBarButtonItem = logoutButton
        
        navBar.items = [navItems]
        
    }
    
    // MARK: Popover Delegate Function
    /* Delegate function for pop up views */
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        return .None
    }
    
    // MARK: Button Handler Functions
    /* Handle the post button being pressed not an outlet since we added the button programmatically*/
    func post()
    {
        // if the selected view controller in the tab bar is not the map view, switch
        if !(self.selectedViewController is MapViewController ){
            self.selectedViewController = mapVC
        }
        
        // prepare the pop over view controller
        postVC.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        postVC.preferredContentSize = self.view.frame.size
        postVC.delegate = mapVC
        
        // TODO: FIX!
        if let popoverController = postVC.popoverPresentationController {
            popoverController.passthroughViews = [mapVC]
        }
        
        // Show spinner while user waits for search of location
        SwiftSpinner.show("Searching for Posted Location", description: "", animated: true)
        
        // check if user location already exists before attempting to post
        OTMClient.sharedInstance().userLocationExists { (exists, objectID, error) -> Void in
            
            
            // hide the spinner
            dispatch_async(dispatch_get_main_queue()){
                SwiftSpinner.hide()
            }
            
            // handle error
            if let userExistsError = error {
                OTMClient.sharedInstance().showAlert(self, title: "Error", message: userExistsError.localizedDescription, actions: ["OK"], completionHandler: nil)
            }
            
            // if the user location already exists
            if exists {
                
                // show alert and ask the user if they want to overwrite the location or not
                OTMClient.sharedInstance().showAlert(self, title: "Location Exists!", message: "You have already submitted your location. Press OK to overwrite.", actions: ["OK","CANCEL"], completionHandler: { (choice) -> Void in
                    
                    // if they want to overwrite
                    if(choice == "OK"){
                        // set the flags on the post view controller
                        self.postVC.isUpdating = true
                        self.postVC.updatingObjectID = objectID
                        
                        // present the post location view
                        if !(self.presentedViewController is UIAlertController) {
                            self.presentViewController(self.postVC, animated: true, completion: nil)
                        }
                    }
                })
            } else {
                // else, no location exists
                
                // set flags
                self.postVC.isUpdating = false
                self.postVC.updatingObjectID = ""
                
                // check that no alert is still being presented before presenting the view
                if !(self.presentedViewController is UIAlertController) {
                    // present the post location view controller
                    self.presentViewController(self.postVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    /* handle the refresh button being pressed */
    func refresh()
    {
        // check for and refresh the relevant view
        if(self.selectedViewController is StudentInfoTableViewController ){
            studentTableVC.refreshTable()
        }
        else {
            mapVC.refreshMap()
        }
    }
    
    /* handle the logout button being pressed */
    func logout(){
        
        // show spinner
        SwiftSpinner.show("Logging Out ...", description: "", animated: true)
        
        // enable activity indicator
        activityIndicatorEnabled(true)
        
        // perform the logout request
        OTMClient.sharedInstance().logout({ (success, error) -> Void in
            
            // logout from facebook
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            
            // handle errors
            if let logoutError = error {
                OTMClient.sharedInstance().showAlert(self, title: "Error", message: logoutError.localizedDescription, actions: ["OK"], completionHandler: nil)
            }
            
            // if logoout was successfull ...
            if(success) {
                // return to login screen
                dispatch_async(dispatch_get_main_queue()){
                    let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
                    self.presentViewController(loginVC, animated: true, completion: nil)
                }
            }
            
            // hide spinner
            SwiftSpinner.hide()
            
            // disable status bar activity indicator
            activityIndicatorEnabled(false)
        
        })
    }
    
    // MARK: Other Functions
    /* function to enable or disable the Distance Tab */
    func distanceTabEnabled(enabled: Bool){
        // disable the tab bar item
        distanceTableVC.tabBarItem.enabled = enabled
    }
}