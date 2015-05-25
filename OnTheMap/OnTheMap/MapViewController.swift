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
    var count = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let loc = CLLocationCoordinate2DMake(35.00,-90)
        let span = MKCoordinateSpanMake(30.00, 50.00)
        let reg = MKCoordinateRegionMake(loc, span)
        self.map.region = reg
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let queue = dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.value), 0)
        
        dispatch_async(queue) {
            
            OTMClient.sharedInstance().getLocationsCount { (result, errorString) -> Void in
                println("COUNT: \(result)")
                
                var counter = Int((result/OTMClient.ParseAPIConstants.LimitPerRequest) + 1)
                
                for(var i = 0; i < counter; i++){
                    dispatch_sync(queue, {
                        
                        OTMData.sharedInstance().fetchData(i * OTMClient.ParseAPIConstants.LimitPerRequest, completionHandler: { (success, result) -> Void in
                            // println("1st we get the results")
                            if(success){
                                self.locations = result
                                println("result: \(result.count)")
                                
                                for location in self.locations {
                                    // println("\(location.lastName), \(location.firstName)")
                                    dispatch_async(dispatch_get_main_queue()){
                                        self.addPinToMap(location)
                                    }
                                }
                            }
                            else {
                                println("done fetching results!!")
                            }
                        })
                    })
                }
            }
        }
        
        //dispatch_async(queue, {
        // })
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

