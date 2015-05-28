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
    
    @IBOutlet weak var addressText: UITextView!
    @IBOutlet weak var mediaURL: UILabel!
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var delegate: MapViewController? = nil
    var currentPlacemark: MKPlacemark!
    
    var isUpdating = false
    var updatingObjectID = ""
    let webVC = WebViewPopOverVC(nibName: "WebViewPopOverVC", bundle: nil)
    var postLocation: MKPlacemark!
    var manager: OneShotLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.hidesWhenStopped = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getAddress(location: CLLocation) -> String {
    
        let loc = location
        let geo = CLGeocoder()
        
        activityIndicator.startAnimating()
        
        geo.reverseGeocodeLocation(location) {
            (placemarks: [AnyObject]!, error: NSError!) in
            
            if placemarks != nil {
                
                let p = placemarks[0] as! CLPlacemark
                let s = ABCreateStringWithAddressDictionary(p.addressDictionary, false)
                
                self.addressText.text = s
            }
            self.activityIndicator.stopAnimating()
        }
        
        return self.addressText.text
    }
    
    @IBAction func findLocation(sender: AnyObject) {
    
        activityIndicator.startAnimating()
        if(currentPlacemark != nil){
            self.delegate?.removePin(currentPlacemark)
        }
        
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
                self.addressText.text = self.getAddress(mp.location!)
                self.currentPlacemark = mp
            }
            self.activityIndicator.stopAnimating()
        }
        
    }
    
    @IBAction func useCurrentLocation(sender: AnyObject) {
        
        activityIndicator.startAnimating()
        
        if(currentPlacemark != nil){
            self.delegate?.removePin(currentPlacemark)
        }
        
        manager = OneShotLocationManager()
        manager!.fetchWithCompletion { (location, error) -> () in
            
            // fetch location or an error
            if let loc = location {
                // println(location)
                let mp = MKPlacemark(coordinate: location!.coordinate, addressDictionary: nil)
                self.postLocation = mp
                self.delegate?.addPin(mp)
                self.addressText.text = self.getAddress(mp.location)
                self.currentPlacemark = mp
            } else if let err = error {
                println(err.localizedDescription)
            }
            self.manager = nil
            self.activityIndicator.stopAnimating()
        }
        
        /*
        let mp = MKPlacemark(coordinate: currentLocation.coordinate, addressDictionary: nil)
        postLocation = mp
        self.delegate?.addPin(mp)
        addressText.text = getAddress(currentLocation)
        */
    }
    
    func setURL(urlString: String){
        mediaURL.text = urlString
    }
    
    @IBAction func browseWeb(sender: UIButton) {
        
        webVC.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        
        webVC.delegate = self
        
        presentViewController(webVC, animated: true, completion: nil)
    }
    
    @IBAction func cancelPost(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func postStudentLocation(sender: AnyObject) {
        
        var noNewLineMapString = (addressText.text as NSString).stringByReplacingOccurrencesOfString("\n", withString: ",")
        var trimmedMapString = (noNewLineMapString as NSString).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        OTMClient.sharedInstance().postUserLocation(postLocation.location!.coordinate.latitude, long: postLocation.location!.coordinate.longitude, mediaURL: self.mediaURL.text!, mapString: trimmedMapString, updateLocationID: updatingObjectID){ (result, errorString) -> Void in
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
