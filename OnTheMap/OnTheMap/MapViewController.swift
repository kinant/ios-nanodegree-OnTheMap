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
        
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        
        dispatch_async(queue, {
            
            for(var i = 0; i < 10; i++){
                dispatch_sync(queue, {
                    
                    OTMData.sharedInstance().fetchData(i*15, completionHandler: { (result) -> Void in
                        // println("1st we get the results")
                        self.locations = result
                        println("result count \(result.count)")
                        // println("then we add the pins!")
                    })
                })
                dispatch_async(dispatch_get_main_queue()){
                    println("adding the pins")
                    self.addPinsToMap()
                }
            }
        })
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

