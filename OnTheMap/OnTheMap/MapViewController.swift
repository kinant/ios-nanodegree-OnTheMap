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
    
    var letRefresh = false
    var isFinishedLoading = false
    
    var locations: [OTMStudentLocation] = [OTMStudentLocation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let loc = CLLocationCoordinate2DMake(35.00,-90)
        let span = MKCoordinateSpanMake(30.00, 50.00)
        let reg = MKCoordinateRegionMake(loc, span)
        self.map.region = reg
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let queue = dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.value), 0)
        
        dispatch_async(queue) {
            
            OTMClient.sharedInstance().getLocationsCount { (result, errorString) -> Void in
                
                var counter = Int((result/OTMClient.ParseAPIConstants.LimitPerRequest) + 1)
                
                for(var i = 0; i <= counter; i++){
                    dispatch_sync(queue, {
                        
                        OTMData.sharedInstance().fetchData(i * OTMClient.ParseAPIConstants.LimitPerRequest, completionHandler: { (success, result) -> Void in
                            if(success){
                                self.locations = result
                                
                                for location in self.locations {
                                    dispatch_async(dispatch_get_main_queue()){
                                        self.addPinToMap(location)
                                    }
                                }
                            }
                            else {
                                //println("done fetching results!!")
                            }
                        })
                    })
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
        if (location.latitude != nil && location.longitude != nil) {
            let newLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            let newAnnotation = OTMAnnotation(coordinate: newLocation, title: (location.firstName + location.lastName), subtitle: location.mediaURL)
            self.map.addAnnotation(newAnnotation)
        }
    }
    
    func addPinsToMap(newLocations: [OTMStudentLocation]){
        
        for location in newLocations {
            // println(location)
            if (location.latitude != nil && location.longitude != nil) {
                let newLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                let newAnnotation = OTMAnnotation(coordinate: newLocation, title: (location.firstName + location.lastName), subtitle: location.mediaURL)
                self.map.addAnnotation(newAnnotation)
                // self.setCenterOfMapToLocation(newLocation)
            }
        }
    }
    
    func addPin(placemark: MKPlacemark){
        map.addAnnotation(placemark)
        setCenterOfMapToLocation(placemark.coordinate)
    }
    
    func removePin(placemark: MKPlacemark){
        map.removeAnnotation(placemark)
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        return .None
    }
    
    @IBAction func postLocation(sender: UIButton) {
        
        println("clicked on post!!!")
        
        postVC.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        // postVC.preferredContentSize = self.view.frame.size
        
        postVC.delegate = self
        
        // check if user location already exists
        OTMClient.sharedInstance().userLocationExists { (exists, objectID) -> Void in
            
            println(exists)
            
            if exists {
                OTMClient.sharedInstance().showAlert(self, title: "Location Exists!", message: "You have already submitted your location. Press OK to overwrite.", actions: ["OK","CANCEL"], completionHandler: { (choice) -> Void in
                    
                    if(choice == "OK"){
                        self.postVC.isUpdating = true
                        self.postVC.updatingObjectID = objectID
                        self.presentViewController(self.postVC, animated: true, completion: nil)
                    }
                })
            } else {
                println("SHOULD TRY TO POST!!")
                self.postVC.isUpdating = false
                self.postVC.updatingObjectID = ""
                
                dispatch_async(dispatch_get_main_queue()){
                    self.presentViewController(self.postVC, animated: true, completion: nil)
                }
            }
        }
    }
}

