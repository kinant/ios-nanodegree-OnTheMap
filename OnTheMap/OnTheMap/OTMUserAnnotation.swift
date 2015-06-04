//
//  OTMUserAnnotation.swift
//  OnTheMap
//
//  Created by KT on 6/4/15.
//  Copyright (c) 2015 Kinan Turjman. All rights reserved.
//

import UIKit
import MapKit

class OTMUserAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    var title: String!
    var subtitle: String!
    
    init(coordinate: CLLocationCoordinate2D, title: String!, subtitle: String!){
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        super.init()
    }
}