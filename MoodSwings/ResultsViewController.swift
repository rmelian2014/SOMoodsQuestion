//
//  ResultsViewController.swift
//  MoodSwings
//
//  Created by Sandeep Hasrajani on 6/3/17.
//  Copyright © 2017 Sandeep Hasrajani. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

class ResultsViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var moodTitle: UILabel!
    
    var moodTitleHolder = ""
    let locationManager = CLLocationManager()
    
    @IBAction func backToMoods(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations[0]
        print(userLocation.coordinate.latitude)
        print(userLocation.coordinate.longitude)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        moodTitle.text = self.moodTitleHolder
        moodTitle.textAlignment = .center
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
}
