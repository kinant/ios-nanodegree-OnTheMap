//
//  AppDelegate.swift
//  OnTheMap
//
//  Created by Kinan Turjman on 5/8/15.
//  Copyright (c) 2015 Kinan Turjman. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // customize navbar appearance
        var navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.tintColor = UIColor.whiteColor()
        navigationBarAppearance.barTintColor = AppColors.MainBlueColor
        navigationBarAppearance.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        
        // customize tab bar appearance
        var tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.tintColor = UIColor.whiteColor()
        tabBarAppearance.barTintColor = AppColors.MainBlueColor
        
        // customize table view appearance
        var tableViewAppearance = UITableView.appearance()
        tableViewAppearance.backgroundColor = AppColors.MainBlueColor
        
        // customize button appearance
        var buttonAppearance = UIButton.appearance()
        var barButtonAppearance = UIBarButtonItem.appearance()
        buttonAppearance.titleLabel?.textColor = .whiteColor()
        barButtonAppearance.tintColor = .whiteColor()
        
        // customize tool bar appearance
        var toolBarAppearance = UIToolbar.appearance()
        toolBarAppearance.backgroundColor = AppColors.MainBlueColor
        toolBarAppearance.barTintColor = AppColors.MainBlueColor
        
        // customize cell appearance
        var distanceCellAppearance = UITableViewCell.appearance()
        distanceCellAppearance.backgroundColor = AppColors.DarkBlueColor
        distanceCellAppearance.textLabel?.textColor = .whiteColor()
        var locationCellAppearance = CustomStudentLocationCell.appearance()
        locationCellAppearance.backgroundColor = AppColors.DarkBlueColor
        
        // customize navbar appearance
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)

        // Override point for customization after application launch.
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(application: UIApplication,
        openURL url: NSURL,
        sourceApplication: String?,
        annotation: AnyObject) -> Bool {
            // so that app is opened again after validating with facebook
            // from: http://www.brianjcoleman.com/tutorial-how-to-use-login-in-facebook-sdk-4-0-for-swift/
            return FBSDKApplicationDelegate.sharedInstance().application(
                application,
                openURL: url,
                sourceApplication: sourceApplication,
                annotation: annotation)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

