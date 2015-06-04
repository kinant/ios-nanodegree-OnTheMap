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
        map.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshMap()
    
    }
    
    func loadData(){
        
        let queue = dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.value), 0)
        
        dispatch_async(queue) {
            
            OTMClient.sharedInstance().getLocationsCount { (result, error) -> Void in
                
                if let getError = error {
                    
                    OTMClient.sharedInstance().showAlert(self, title: getError.domain, message: getError.localizedDescription, actions: ["OK"], completionHandler: { (choice) -> Void in
                        // do nothing
                    })
                    
                } else {
                    
                    var counter = Int((result/OTMClient.ParseAPIConstants.LimitPerRequest) + 1)
                    
                    for(var i = 0; i <= counter; i++){
                        dispatch_sync(queue, {
                            
                            OTMData.sharedInstance().fetchData(self, skip: i * OTMClient.ParseAPIConstants.LimitPerRequest, completionHandler: { (result) -> Void in
                                
                                if let locations = result {
                                    self.locations = locations
                                    
                                    for location in self.locations {
                                        dispatch_async(dispatch_get_main_queue()){
                                            self.addPinToMap(location)
                                        }
                                    }
                                }
                                else {
                                    OTMClient.sharedInstance().showAlert(self, title: "OTM Error", message: "Unable to fetch locations ", actions: ["OK"], completionHandler: { (choice) -> Void in
                                        // do nothing
                                    })
                                }
                            })
                        })
                    }
                    
                    var tabBarC = self.tabBarController as! TabBarVC
                    tabBarC.distanceTabEnabled(true)
                }
            }
        }
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
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        // println("in here!!!!")
        
        var v: MKAnnotationView! = nil
        
        let identifier = "pin"
        
        v = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
        
        if v == nil {
            v = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            (v as! MKPinAnnotationView).pinColor = .Purple
            v.canShowCallout = true
            v.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
        }
        v.annotation = annotation
        
        return v
    }
    
    func test(){
        // println("test")
    }
    
    func refreshMap()
    {
        let loc = CLLocationCoordinate2DMake(35.00,-90)
        let span = MKCoordinateSpanMake(30.00, 50.00)
        let reg = MKCoordinateRegionMake(loc, span)
        self.map.region = reg
        
        map.removeAnnotations(map.annotations)
        OTMData.sharedInstance().locationsList.removeAll()
        loadData()
    }
    
    func setCenterOfMapToLocation(location: CLLocationCoordinate2D){
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: location, span: span)
        map.setRegion(region, animated: true)
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        
        let location = view.annotation as! OTMAnnotation
        
        NSURL.validateUrl(location.subtitle!, completion: { (success, urlString, error) -> Void in
            
            if(success){
                
                var url = NSURL(string: urlString!)
                UIApplication.sharedApplication().openURL(url!)
            } else {
                OTMClient.sharedInstance().showAlert(self, title: "Error", message: (error as String), actions: ["OK"], completionHandler: { (choice) -> Void in
                    
                })
            }
        })
    }
}