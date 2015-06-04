//
//  Utility.swift
//  OnTheMap
//
//  Created by KT on 5/28/15.
//  Copyright (c) 2015 Kinan Turjman. All rights reserved.
//

import Foundation

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

struct AppColors {
    static let MainBlueColor = UIColor(red: 118/255, green: 205/255, blue: 252/255, alpha: 1.0)
    static let LightBlueColor = UIColor(red: 113/255, green: 203/255, blue: 255/255, alpha: 1.0)
    static let DarkBlueColor = UIColor(red: 94/255, green: 166/255, blue: 207/255, alpha: 1.0)
}