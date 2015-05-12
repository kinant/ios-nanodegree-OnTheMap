//
//  PostLocationPopOverVC.swift
//  OnTheMap
//
//  Created by Kinan Turjman on 5/12/15.
//  Copyright (c) 2015 Kinan Turjman. All rights reserved.
//

import UIKit
import MapKit

class PostLocationPopOverVC: UIViewController, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()
    
    @IBOutlet weak var addressText: UITextView!
    
    var delegate: MapViewController? = nil
    var currentLocation:CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        currentLocation = delegate?.map.userLocation.location
        println(self.delegate?.map.userLocation.coordinate.latitude)
        locationManager.startUpdatingLocation()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        let newLocation = manager.location
        println(newLocation.coordinate.latitude)
        println(newLocation.coordinate.longitude)
        currentLocation = newLocation
        
        return
    }
    
    @IBAction func findLocation(sender: AnyObject) {
    
        let s = addressText.text
        let geo = CLGeocoder()
        
        geo.geocodeAddressString(s) {
            (placemarks: [AnyObject]!, error: NSError!) in
            
            if nil == placemarks {
                println(error.localizedDescription)
            } else {
                let p = placemarks[0] as? CLPlacemark
                let mp = MKPlacemark(placemark: p)
                self.delegate?.addPin(mp)
            }
        }
    }
    
    @IBAction func useCurrentLocation(sender: AnyObject) {
        
        // println(self.currentLocation.coordinate.longitude)
        // println(self.currentLocation.coordinate.latitude)
        
        let mp = MKPlacemark(coordinate: currentLocation.coordinate, addressDictionary: nil)
        self.delegate?.addPin(mp)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
