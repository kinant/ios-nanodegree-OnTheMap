//
//  MapView.swift
//  OnTheMap
//
//  Created by Kinan Turjman on 5/11/15.
//  Copyright (c) 2015 Kinan Turjman. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, UIPopoverPresentationControllerDelegate {
    
    let postVC = PostLocationPopOverVC(nibName: "PostLocationPopOverVC", bundle: nil)
    
    @IBOutlet weak var map: MKMapView!
    
    var locations: [OTMStudentLocation] = [OTMStudentLocation]()
    var isFinishedLoading = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // let loc = CLLocationCoordinate2DMake(34.927752,-120.217608)
        // let span = MKCoordinateSpanMake(0.015, 0.015)
        // let reg = MKCoordinateRegionMake(loc, span)
        // self.map.region = reg
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        println("in here 1!")
        
        // while(!isFinishedLoading) {
        for(var i = 0; i < 3; i++){
            self.locations.removeAll(keepCapacity: false)
            println("in here 2!")
            OTMData.sharedInstance().fetchData { (result) -> Void in
                println(result)
                self.locations = result
            
                if result.count == 0 {
                    self.isFinishedLoading = true
                }
            
                for location in self.locations {
                    println("adding \(location.firstName) location: \(location.latitude), \(location.longitude)")
                
                    dispatch_async(dispatch_get_main_queue()){
                        self.addPinToMap(location)
                    }
                }
            }
        }
    }
    
    func setCenterOfMapToLocation(location: CLLocationCoordinate2D){
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: location, span: span)
        map.setRegion(region, animated: true)
    }
    
    func addPinToMap(location: OTMStudentLocation){
        let newLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let newAnnotation = OTMAnnotation(coordinate: newLocation, title: (location.firstName + location.lastName), subtitle: location.mediaURL)
        self.map.addAnnotation(newAnnotation)
    }
    
    func addPinsToMap(){
        
        for location in locations {
            let newLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            let newAnnotation = OTMAnnotation(coordinate: newLocation, title: (location.firstName + location.lastName), subtitle: location.mediaURL)
            self.map.addAnnotation(newAnnotation)
        }
    }
    
    func addPin(placemark: MKPlacemark){
        map.addAnnotation(placemark)
        setCenterOfMapToLocation(placemark.coordinate)
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        return .None
    }
    
    @IBAction func postLocation(sender: UIButton) {
        
        postVC.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        // postVC.preferredContentSize = self.view.frame.size
        
        postVC.delegate = self
        
        // check if user location already exists
        OTMClient.sharedInstance().userLocationExists { (exists, objectID) -> Void in
            if exists {
                self.postVC.isUpdating = true
                self.postVC.updatingObjectID = objectID
            }
        }
        
        presentViewController(postVC, animated: true, completion: nil)
    }
}

