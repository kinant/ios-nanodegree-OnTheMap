//
//  MapView.swift
//  OnTheMap
//
//  Created by Kinan Turjman on 5/11/15.
//  Copyright (c) 2015 Kinan Turjman. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    
    @IBOutlet weak var map: MKMapView!
    
    var locations: [OTMStudentInformation] = [OTMStudentInformation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // let loc = CLLocationCoordinate2DMake(34.927752,-120.217608)
        // let span = MKCoordinateSpanMake(0.015, 0.015)
        // let reg = MKCoordinateRegionMake(loc, span)
        // self.map.region = reg
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        OTMClient.sharedInstance().getUserList { (result, errorString) -> Void in
            
            if let information = result {
                self.locations = information
                dispatch_async(dispatch_get_main_queue()) {
                    self.addPinsToMap()
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setCenterOfMapToLocation(location: CLLocationCoordinate2D){
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: location, span: span)
        map.setRegion(region, animated: true)
    }
    
    func addPinsToMap(){
        
        for location in locations {
            let newLocation = CLLocationCoordinate2D(latitude: location.lat, longitude: location.long)
            let newAnnotation = OTMAnnotation(coordinate: newLocation, title: location.name, subtitle: location.mediaURL)
            map.addAnnotation(newAnnotation)
            // setCenterOfMapToLocation(newLocation)
        }
    }
}

