//
//  TabBarViewController.swift
//  OnTheMap
//
//  Created by KT on 6/2/15.
//  Copyright (c) 2015 Kinan Turjman. All rights reserved.
//

import Foundation

class TabBarViewController: UITabBarController, UIPopoverPresentationControllerDelegate {
    
    let owner = UIView()
    let menuVC = MenuPopOverVC(nibName: "PopUpMenuVC", bundle: nil)
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        return .None
    }
    
    @IBAction func menuButtonPressed(sender: UIButton) {
        
        menuVC.modalPresentationStyle = UIModalPresentationStyle.Popover
        
        menuVC.preferredContentSize = CGSizeMake(200, 50)
        
        if let popoverController = menuVC.popoverPresentationController {
            popoverController.sourceView = self.navigationController?.navigationBar
            popoverController.sourceRect = CGRect(x: 200, y: 0, width: 200, height: 50)
            popoverController.permittedArrowDirections = UIPopoverArrowDirection.Up
            popoverController.delegate = self
            //popoverVC.delegate = self
        }
        
        presentViewController(menuVC, animated: false, completion: nil)
    }
}
