//
//  PostLocationPopOverVC.swift
//  OnTheMap
//
//  Created by Kinan Turjman on 5/12/15.
//  Copyright (c) 2015 Kinan Turjman. All rights reserved.
//

import UIKit
import MapKit
import AddressBookUI

class PostLocationPopOverVC: UIViewController, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()
    
    @IBOutlet weak var addressText: UITextView!
    @IBOutlet weak var mediaURL: UILabel!
    
    var delegate: MapViewController? = nil
    var currentLocation:CLLocation!
    
    var isUpdating = false
    var updatingObjectID = ""
    
    let webVC = WebViewPopOverVC(nibName: "WebViewPopOverVC", bundle: nil)
    
    var postLocation: MKPlacemark!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        currentLocation = delegate?.map.userLocation.location
        // println(self.delegate?.map.userLocation.coordinate.latitude)
        locationManager.startUpdatingLocation()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        let newLocation = manager.location
        // println("New location!")
        // println(newLocation.coordinate.latitude)
        // println(newLocation.coordinate.longitude)
        currentLocation = newLocation
        
        return
    }
    
    func getAddress(location: CLLocation) -> String {
    
        let loc = location
        let geo = CLGeocoder()
        
        geo.reverseGeocodeLocation(location) {
            (placemarks: [AnyObject]!, error: NSError!) in
            
            if placemarks != nil {
                
                let p = placemarks[0] as! CLPlacemark
                let s = ABCreateStringWithAddressDictionary(p.addressDictionary, false)
                
                self.addressText.text = s

            }
            
        }
        
        return self.addressText.text
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
                self.postLocation = mp
                self.delegate?.addPin(mp)
            }
        }
    }
    
    @IBAction func useCurrentLocation(sender: AnyObject) {
        
        // println(self.currentLocation.coordinate.longitude)
        // println(self.currentLocation.coordinate.latitude)
        
        let mp = MKPlacemark(coordinate: currentLocation.coordinate, addressDictionary: nil)
        
        // mp.title = self.addressText.text
        postLocation = mp
        self.delegate?.addPin(mp)
        // self.dismissViewControllerAnimated(true, completion: nil)
        addressText.text = getAddress(currentLocation)
    }
    
    func setURL(urlString: String){
        mediaURL.text = urlString
    }
    
    @IBAction func browseWeb(sender: UIButton) {
        
        webVC.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        // postVC.preferredContentSize = self.view.frame.size
        
        webVC.delegate = self
        
        presentViewController(webVC, animated: true, completion: nil)
    }
    
    
    @IBAction func postStudentLocation(sender: AnyObject) {
        /*
        self.latitude = dictionary["latitude"] as? Double
        self.longitude = dictionary["longitude"] as? Double
        
        self.firstName = dictionary["firstName"] as? String
        self.lastName = dictionary["lastName"] as? String
        
        self.mediaURL = dictionary["mediaURL"] as? String
        */
        // OTMClient.sharedInstance().postStudentLocation(
        
        println("will post!")
        println("lat: \(postLocation.location!.coordinate.latitude)")
        println("long: \(postLocation.location!.coordinate.longitude)")
        println("media: \(mediaURL.text)")
        println("mapString: \(addressText.text)")
        
        var noNewLineMapString = (addressText.text as NSString).stringByReplacingOccurrencesOfString("\n", withString: ",")
        var trimmedMapString = (noNewLineMapString as NSString).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        OTMClient.sharedInstance().postUserLocation(postLocation.location!.coordinate.latitude, long: postLocation.location!.coordinate.longitude, mediaURL: self.mediaURL.text!, mapString: trimmedMapString, updateLocationID: updatingObjectID){ (result, errorString) -> Void in
            
            println(result)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
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
