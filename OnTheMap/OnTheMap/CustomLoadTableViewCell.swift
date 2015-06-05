//
//  CustomLoadTableViewCell.swift
//  OnTheMap
//
//  Created by KT on 5/28/15.
//  Copyright (c) 2015 Kinan Turjman. All rights reserved.
//

import Foundation

/* Custom table view cell for the last row of the student locations table. 
 * This last row displays an activity indicator to indicate the loading
 * of more data.
*/

class CustomLoadTableViewCell: UITableViewCell {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! // activity indicator outlet
    
}