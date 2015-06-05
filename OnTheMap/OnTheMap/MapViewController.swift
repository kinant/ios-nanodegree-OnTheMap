//
//  MapView.swift
//  OnTheMap
//
//  Created by Kinan Turjman on 5/11/15.
//  Copyright (c) 2015 Kinan Turjman. All rights reserved.
//

import UIKit
import MapKit

/* This class handles the MapView and all associated map functions */
class MapViewController: UIViewController, MKMapViewDelegate, UIPopoverPresentationControllerDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var map: MKMapView! // mapview outlet
    
    // MARK: Properties
    var refresh = true // flag for enabling refresh of data
    var locations: [OTMStudentLocation] = [OTMStudentLocation]() // array of student location objects
    
    // MARK: Overriden View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // if the map is allowed to refresh data then...
        if refresh {
            
            // disable the distance tab item (this is only enabled when all data is loaded)
            dispatch_async(dispatch_get_main_queue()){
                var tabBarC = self.tabBarController as! TabBarVC
                tabBarC.distanceTabEnabled(false)
            }
            
            // proceed to refresh the map
            refreshMap()
        }
    
    }
    
    // MARK: Data Functions
    
    func loadData(){
        
        // start the status bar activity indicator
        activityIndicatorEnabled(true)
        
        // get the Class Utility Queue for the background thread
        let queue = dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.value), 0)
        
        // add task to queue asynchronously
        dispatch_async(queue) {
            
            /* We will fetch the locations in a batched form. First we need to determine how many
             * locations there are stored in Parse in total */
            OTMClient.sharedInstance().getLocationsCount { (result, error) -> Void in
                
                // handle error, display alert
                if let getError = error {
                    
                    OTMClient.sharedInstance().showAlert(self, title: getError.domain, message: getError.localizedDescription, actions: ["OK"], completionHandler: nil)
                
                // no error
                } else {
                    
                    // set the counter (based on number of results and the limits per request)
                    var counter = Int((result/OTMClient.ParseAPIConstants.LimitPerRequest) + 1)
                    
                    // perform the fetch data task counter number of times
                    for(var i = 0; i <= counter; i++){
                        
                        // add task to queue
                        dispatch_sync(queue, {
                            
                            // fetch the data, skip the relevant amount of objects
                            OTMData.sharedInstance().fetchData(self, skip: i * OTMClient.ParseAPIConstants.LimitPerRequest, completionHandler: { (result) -> Void in
                                
                                // if results are returned
                                if let locations = result {
                                    
                                    // set the locations
                                    self.locations = locations
                                    
                                    // iterate over each location and add it to the map
                                    for location in self.locations {
                                        dispatch_async(dispatch_get_main_queue()){
                                            self.addPinToMap(location)
                                        }
                                    }
                                    
                                    // if locations is returned empty, then we are done loading
                                    if locations.count <= 0 {
                                        
                                        // enable the distance tab bar item
                                        dispatch_async(dispatch_get_main_queue()){
                                            var tabBarC = self.tabBarController as! TabBarVC
                                            tabBarC.distanceTabEnabled(true)
                                        }
                                        
                                        // disable the activity indicator
                                        activityIndicatorEnabled(false)
                                    }
                                    
                                }
                                else {
                                    // handle the error
                                    OTMClient.sharedInstance().showAlert(self, title: "OTM Error", message: "Unable to fetch locations ", actions: ["OK"], completionHandler: nil)
                                }
                            })
                        })
                    }
                }
            }
        }
    }
    
    // MARK: Map Functions
    /* adds a pin or placemark to the map */
    func addPinToMap(location: OTMStudentLocation){
        
        // first check that the location is valid (ie. no nil values)
        if (location.isValid()) {
            
            // create the new location
            let newLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            // create the new annotation
            let newAnnotation = OTMAnnotation(coordinate: newLocation, title: "\(location.firstName) \(location.lastName)", subtitle: location.mediaURL)
            
            // add the annotation to the map
            self.map.addAnnotation(newAnnotation)
        }
    }
    
    /* adds a placemark to the map, given by the placemark parameter 
     * this is used to display the location where the user will want to post
     * their location
    */
    func addPin(placemark: MKPlacemark){
        dispatch_async(dispatch_get_main_queue()){
            self.map.addAnnotation(placemark)
            self.setCenterOfMapToLocation(placemark.coordinate)
        }
    }
    
    /* removes a placemark from the map */
    func removePin(placemark: MKPlacemark){
        map.removeAnnotation(placemark)
    }
    
    /* function that refreshes the mapview
    * Help from: Chapter 21: Maps, from "Programming iOS 8: Dive Deep Into Views, View Controllers, and Frameworks" by Matt neuburg. 5th Edition. O'Reilly. 2014.
    */
    func refreshMap()
    {
        // set the region and span being viewed
        let loc = CLLocationCoordinate2DMake(35.00,-90)
        let span = MKCoordinateSpanMake(30.00, 50.00)
        let reg = MKCoordinateRegionMake(loc, span)
        self.map.region = reg
        
        // remove all annotations
        map.removeAnnotations(map.annotations)
        
        // remove all locations stored in the data class
        OTMData.sharedInstance().locationsList.removeAll()
        
        // load data
        loadData()
    }
    
    /* Sets the center of the map to show the location given by the parameter
    * Help from: Chapter 21: Maps, from "Programming iOS 8: Dive Deep Into Views, View Controllers, and Frameworks" by Matt neuburg. 5th Edition. O'Reilly. 2014.
    */
    func setCenterOfMapToLocation(location: CLLocationCoordinate2D){
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        map.setRegion(region, animated: true)
    }
    
    /* zooms to a location on the map. similar to the set center of map function (which this function uses)
    * this function is called from the distance table view to display the location of the user
    */
    func zoomToLocation(lat: Double, long: Double){
        
        // create the location and center the map
        var newLocation = CLLocationCoordinate2DMake(lat, long)
        setCenterOfMapToLocation(newLocation)
        
        // enable the distance tab bar item (so the user can go back to table without refreshing data
        dispatch_async(dispatch_get_main_queue()){
            var tabBarC = self.tabBarController as! TabBarVC
            tabBarC.distanceTabEnabled(true)
            
            // allow the data to be refreshed afterwards
            self.refresh = true
        }
    }
    
    // MARK: mapView Delegate Functions
    
    /* mapView delegate function to customize the annotation view 
     * Help from: Chapter 21: Maps, from "Programming iOS 8: Dive Deep Into Views, View Controllers, and Frameworks" by Matt neuburg. 5th Edition. O'Reilly. 2014.
    */
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        // get the pin image
        var pinImage = UIImage(named: "red_placemark")
        
        // create the annotation view
        var v: MKAnnotationView! = nil
        let identifier = "pin"
        
        v = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
        
        if v == nil {
            v = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
            // allow callout to be shown
            v.canShowCallout = true
            
            // add the accessory button
            v.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
            
            // set the image
            v.image = pinImage
            v.bounds.size.height /= 3.0
            v.bounds.size.width /= 3.0
        }
        
        v.annotation = annotation
        
        return v
    }
    
    /* delegate function that handles the press of the callout accessory */
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        
        // obtain the location annotation being pressed
        let location = view.annotation as! OTMAnnotation
        
        // validate the URL from the annotation
        NSURL.validateUrl(location.subtitle!, completion: { (success, urlString, error) -> Void in
            
            // if the url is valid, browse to it
            if(success){
                OTMClient.sharedInstance().browseToURL(urlString!)
            } else {
                
                // if not valid, show alert with error
                OTMClient.sharedInstance().showAlert(self, title: "Error", message: (error as String), actions: ["OK"], completionHandler: nil)
            }
        })
    }
}