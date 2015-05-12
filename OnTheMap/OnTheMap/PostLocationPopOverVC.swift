//
//  PostLocationPopOverVC.swift
//  OnTheMap
//
//  Created by Kinan Turjman on 5/12/15.
//  Copyright (c) 2015 Kinan Turjman. All rights reserved.
//

import UIKit
import MapKit

class PostLocationPopOverVC: UIViewController {

    @IBOutlet weak var addressText: UITextView!
    
    var delegate: MapViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
