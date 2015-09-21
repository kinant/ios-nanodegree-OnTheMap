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

/* Handles the Post Location View Controller */
class PostLocationPopOverVC: UIViewController, CLLocationManagerDelegate, UITextViewDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var addressText: UITextView! // address text view outlet
    @IBOutlet weak var mediaURL: UILabel! // the label that shows the URL
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var map: MKMapView!
    
    // MARK: Properties
    var delegate: MapViewController? = nil
    var currentPlacemark: MKPlacemark! // stores the current placemark (of user's looked up location)
    var isUpdating = false // flag for when the user is updating their location
    var updatingObjectID = "" // variable to store the ID of the object being updated
    
    let webVC = WebViewPopOverVC(nibName: "WebViewPopOverVC", bundle: nil) // loads the webview nib
    
    var postLocation: MKPlacemark! // the location to be posted
    
    // will use OneShotLocation manager to get user's location ONCE
    // from: https://github.com/icanzilb/OneShotLocationManager
    var manager: OneShotLocationManager? // manager for the oneshotlocation manager
    
    // flags are used for enabling/disabling the post button depending on if the user
    // has selected a location and an URL
    var hasAddress = false
    var hasURL = false
    
    // MARK: Overriden View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("in here!")
        
        addressText.delegate = self
        
        // adds gesture recognizer to dissmiss keyboard when screen is tapped
        let tapScreen = UITapGestureRecognizer(target: self, action: "hideKeyboard")
        self.view.addGestureRecognizer(tapScreen)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        // set flags to false
        hasAddress = false
        hasURL = false
        
        // disable the post button
        postButton.enabled = false
    }
    
    // MARK: textView Delegate Functions
    /* textview delegate function when editing */
    func textViewDidBeginEditing(textView: UITextView) {
        // remove all text
        textView.text = ""
        
        // disable post button
        postButton.enabled = false
    }
    
    // MARK: Other Functions
    /* hides the keyboard */
    func hideKeyboard(){
        addressText.resignFirstResponder()
    }
    
    /* set's the URL shown in the label */
    func setURL(urlString: String){
        
        // unhide and set text
        mediaURL.hidden = false
        mediaURL.text = urlString
        
        // set flag
        hasURL = true
        
        // check if address has been set, if so, enable post button
        if(hasAddress) {
            postButton.enabled = true
        }
    }
    
    /* function that reverse geocodes a location, get's the address and sets it to the text on the textview 
     * Code from:
    */
    func getAddress(location: CLLocation) -> String {
    
        let loc = location
        let geo = CLGeocoder()
        
        // do reverse geocoding
        geo.reverseGeocodeLocation(location) { (placemarks, error) -> Void in
            if placemarks != nil {
                
                let p = placemarks?.first!
                let s = ABCreateStringWithAddressDictionary(p!.addressDictionary!, false)
                
                // set the text on the textview
                self.addressText.text = s
            }
        }
        
        return self.addressText.text
    }
    
    // MARK: IBAction Functions (for button presses)
    
    /* finds a location based on the user input */
    @IBAction func findLocation(sender: AnyObject) {
        
        hideKeyboard()
        
        // show spinner and activity indicator
        SwiftSpinner.show("Searching for location ... ", description: "", animated: true)
        activityIndicatorEnabled(true)
        
        // remove the existing found pin (if any)
        if(currentPlacemark != nil){
            self.delegate?.removePin(currentPlacemark)
        }
        
        let s = addressText.text
        let geo = CLGeocoder()
        
        geo.geocodeAddressString(s) {
            (placemarks: [CLPlacemark]?, error: NSError?) in
            
            // handle errors
            if nil == placemarks {
                
                // show spinner and set flag
                SwiftSpinner.show("Location not found ... ", description: error!.localizedDescription, animated: false)
                self.hasAddress = false
            } else {
                
                // set flag and show spinner
                self.hasAddress = true
                SwiftSpinner.show("Location found! ", description: "", animated: false)
                
                // create the placemark, add the pin to the map view
                let p = placemarks!.first
                let mp = MKPlacemark(placemark: p!)
                self.postLocation = mp
                self.delegate?.addPin(mp)
                
                // set the textview text and the currently found placemark
                self.addressText.text = self.getAddress(mp.location!)
                self.currentPlacemark = mp
                
                // if URL has already been set, enable the post button
                if(self.hasURL){
                    self.postButton.enabled = true
                }
                
                // delay and hide the indicator and spinner
                delay(0.5){
                    SwiftSpinner.hide()
                    activityIndicatorEnabled(false)
                }
            }
        }
        
    }
    
    /* gets the user current location */
    @IBAction func useCurrentLocation(sender: AnyObject) {
        
        hideKeyboard()
        
        // show spinner and indicator
        SwiftSpinner.show("Getting current location... ", description: "", animated: true)
        activityIndicatorEnabled(true)
        
        // remove the existing found pin (if any)
        if(currentPlacemark != nil){
            self.delegate?.removePin(currentPlacemark)
        }
        
        // use one shot location manager to get user's current location
        manager = OneShotLocationManager()
        manager!.fetchWithCompletion { (location, error) -> () in
            
            // fetch location or an error
            if let loc = location {
                // location found
                
                // set flag and show spinner success message
                self.hasAddress = true
                SwiftSpinner.show("Location found! ", description: "", animated: false)
                
                // create placemark and add pin to the map
                let mp = MKPlacemark(coordinate: location!.coordinate, addressDictionary: nil)
                self.postLocation = mp
                self.delegate?.addPin(mp)
                
                // set the textview text and the currently found placemark
                self.addressText.text = self.getAddress(mp.location!)
                self.currentPlacemark = mp
                
                // check if URL has already been set and enable post button if so
                if(self.hasURL){
                    self.postButton.enabled = true
                }
                
                // delay and hide the indicator and spinner
                delay(0.5){
                    SwiftSpinner.hide()
                    activityIndicatorEnabled(false)
                }
                
            } else if let err = error {
                // handle errors
                
                // set flag and show spinner with error message
                self.hasAddress = false
                SwiftSpinner.show("Location not found ... ", description: err.localizedDescription, animated: false)
            }
            self.manager = nil
        }
    }
    
    /* handles the browse web button, for using a browser to browse for the media URL */
    @IBAction func browseWeb(sender: UIButton) {
        
        // present the browser
        webVC.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        
        webVC.delegate = self
        
        // check that no other view has been presented
        if !(self.presentedViewController is UIAlertController) {
            presentViewController(webVC, animated: true, completion: nil)
        }
    }
    
    /* handles cancel button being pressed */
    @IBAction func cancelPost(sender: AnyObject) {
        
        // remove any existing found placemark
        if currentPlacemark != nil {
            delegate?.removePin(currentPlacemark)
        }
        
        // refresh the mapview and dismiss the post view controller
        self.delegate?.refreshMap()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /* handles the posting of user data */
    @IBAction func postStudentLocation(sender: AnyObject) {
        
        // remove newlines or '/n' from the textview text and then trimm whitespaces
        var noNewLineMapString = (addressText.text as NSString).stringByReplacingOccurrencesOfString("\n", withString: ",")
        var trimmedMapString = (noNewLineMapString as NSString).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        activityIndicatorEnabled(true)
        
        // post the student's location
        OTMClient.sharedInstance().postUserLocation(postLocation.location!.coordinate.latitude, long: postLocation.location!.coordinate.longitude, mediaURL: self.mediaURL.text!, mapString: trimmedMapString, updateLocationID: updatingObjectID){ (error) -> Void in
            
            // handle errors
            if let postError = error {
                
                // show alert
                OTMClient.sharedInstance().showAlert(self, title: postError.domain, message: postError.localizedDescription, actions: ["OK"], completionHandler: { (choice) -> Void in
                    
                    // dismiss the viewcontroller once the alert is dismissed
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                })
            } else {
                // no error, show alert that post was successfulll
                OTMClient.sharedInstance().showAlert(self, title: "OTM POST", message: "Post Location was Successfull!", actions: ["OK"], completionHandler: { (choice) -> Void in
                    
                    // refresh the mapview and dismiss post location view controller
                    self.delegate?.refreshMap()
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            }
            
            activityIndicatorEnabled(true)
        }
    }
}
