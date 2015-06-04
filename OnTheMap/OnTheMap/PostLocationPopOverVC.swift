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
    
    var delegate: MapViewController? = nil
    var currentPlacemark: MKPlacemark!
    
    var isUpdating = false
    var updatingObjectID = ""
    let webVC = WebViewPopOverVC(nibName: "WebViewPopOverVC", bundle: nil)
    var postLocation: MKPlacemark!
    var manager: OneShotLocationManager?
    
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        
        delegate?.test()
        delegate?.test()
        delegate?.test()
        delegate?.test()
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
        
        SwiftSpinner.show("Searching for location ... ", description: "", animated: true)
        
        if(currentPlacemark != nil){
            self.delegate?.removePin(currentPlacemark)
        }
        
        let s = addressText.text
        let geo = CLGeocoder()
        
        geo.geocodeAddressString(s) {
            (placemarks: [AnyObject]!, error: NSError!) in
            
            if nil == placemarks {
                SwiftSpinner.show("Location not found ... ", description: error.localizedDescription, animated: false)
                // println(error.localizedDescription)
            } else {
                SwiftSpinner.show("Location found! ", description: "", animated: false)
                let p = placemarks[0] as? CLPlacemark
                let mp = MKPlacemark(placemark: p)
                self.postLocation = mp
                self.delegate?.addPin(mp)
                self.addressText.text = self.getAddress(mp.location!)
                self.currentPlacemark = mp
                
                delay(0.5){
                    SwiftSpinner.hide()
                }
            }
        }
        
    }
    
    @IBAction func useCurrentLocation(sender: AnyObject) {
        
        SwiftSpinner.show("Getting current location... ", description: "", animated: true)
        
        if(currentPlacemark != nil){
            self.delegate?.removePin(currentPlacemark)
        }
        
        manager = OneShotLocationManager()
        manager!.fetchWithCompletion { (location, error) -> () in
            
            // fetch location or an error
            if let loc = location {
                SwiftSpinner.show("Location found! ", description: "", animated: false)
                let mp = MKPlacemark(coordinate: location!.coordinate, addressDictionary: nil)
                self.postLocation = mp
                self.delegate?.addPin(mp)
                self.addressText.text = self.getAddress(mp.location)
                self.currentPlacemark = mp
                
                delay(0.5){
                    SwiftSpinner.hide()
                }
                
            } else if let err = error {
                SwiftSpinner.show("Location not found ... ", description: err.localizedDescription, animated: false)
                // println(err.localizedDescription)
            }
            self.manager = nil
        }
    }
    
    func setURL(urlString: String){
        mediaURL.text = urlString
    }
    
    @IBAction func browseWeb(sender: UIButton) {
        
        webVC.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        
        webVC.delegate = self
        
        if !(self.presentedViewController is UIAlertController) {
            presentViewController(webVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelPost(sender: AnyObject) {
        delegate?.removePin(currentPlacemark)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func postStudentLocation(sender: AnyObject) {
        
        var noNewLineMapString = (addressText.text as NSString).stringByReplacingOccurrencesOfString("\n", withString: ",")
        var trimmedMapString = (noNewLineMapString as NSString).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        OTMClient.sharedInstance().postUserLocation(postLocation.location!.coordinate.latitude, long: postLocation.location!.coordinate.longitude, mediaURL: self.mediaURL.text!, mapString: trimmedMapString, updateLocationID: updatingObjectID){ (error) -> Void in
            
            if let postError = error {
                OTMClient.sharedInstance().showAlert(self, title: postError.domain, message: postError.localizedDescription, actions: ["OK"], completionHandler: { (choice) -> Void in
                    
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                })
            } else {
                OTMClient.sharedInstance().showAlert(self, title: "OTM POST", message: "Post Locaiton was Successfull!", actions: ["OK"], completionHandler: { (choice) -> Void in
                    self.delegate?.refreshMap()
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            }
        }
    }
}
