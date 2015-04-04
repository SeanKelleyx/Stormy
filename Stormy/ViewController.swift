//
//  ViewController.swift
//  Stormy
//
//  Created by Sean Kelley on 3/27/15.
//  Copyright (c) 2015 SeanKelley. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var precipLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var refreshActivityIndicator: UIActivityIndicatorView!
    
    let locationManager = CLLocationManager()
    private let apiKey = "4a7a86784dd76767baf4435021887aa1"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshActivityIndicator.hidden = true
        
        getLocationInfo()
    }
    
    func getLocationInfo(){
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        println(manager.location.coordinate.latitude)
        println(manager.location.coordinate.longitude)
        
        var latLongString = "\(manager.location.coordinate.latitude),\(manager.location.coordinate.longitude)"
        
        CLGeocoder().reverseGeocodeLocation( manager.location, completionHandler: { (placemarks, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if (error == nil){
                    if (placemarks.count > 0) {
                        let pm = placemarks[0] as CLPlacemark
                        self.setCityName(pm, locationCoords: latLongString)
                    } else {
                        println("Error with data")
                    }
                }else{
                    println("Error: " + error.localizedDescription)
                    return
                }
            })
        })
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error: " + error.localizedDescription)
    }
    
    func setCityName(placemark: CLPlacemark, locationCoords: String){
        self.locationManager.stopUpdatingLocation()
        getCurrentWeatherData(locationCoords, locationText: placemark.locality)
        println(placemark.locality)
    }
    
    func getCurrentWeatherData(locationCoords: String, locationText: String){
        let baseURL = NSURL(string: "https://api.forecast.io/forecast/\(apiKey)/")
        let forecastURL = NSURL(string: locationCoords, relativeToURL: baseURL)
        let sharedSession = NSURLSession.sharedSession()
        let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(forecastURL!, completionHandler:
            {(location: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
                if(error == nil){
                    let dataObject = NSData(contentsOfURL: location)
                    let weatherDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataObject!, options: nil, error: nil) as NSDictionary
                    let currentWeather = Current(weatherDictionary: weatherDictionary, locationString: locationText)
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.iconImage.image = currentWeather.icon
                        self.locationLabel.text = currentWeather.location
                        self.timeLabel.text = "At \(currentWeather.currentTime!) it is"
                        self.tempLabel.text = "\(currentWeather.temperature)"
                        self.humidityLabel.text = "\(Int(currentWeather.humidity * 100))%"
                        self.precipLabel.text = "\(Int(currentWeather.precipProbability * 100))%"
                        self.descriptionLabel.text = currentWeather.summary
                        self.refreshActivityIndicator.stopAnimating()
                        self.refreshActivityIndicator.hidden = true
                        self.refreshButton.hidden = false
                    })
                } else {
                    let networkIssueController = UIAlertController(title: "Error", message: "Unable to load data. Connectivity error!", preferredStyle: .Alert)
                    let okButton = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    let cancelButton = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                    networkIssueController.addAction(okButton)
                    networkIssueController.addAction(cancelButton)
                    self.presentViewController(networkIssueController, animated: true, completion: nil)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.refreshActivityIndicator.stopAnimating()
                        self.refreshActivityIndicator.hidden = true
                        self.refreshButton.hidden = false
                    })
                }
        })
        downloadTask.resume()
    }
    
    @IBAction func refresh() {
        refreshButton.hidden = true
        refreshActivityIndicator.hidden = false
        refreshActivityIndicator.startAnimating()
        //getCurrentWeatherData()
        //getLocationInfo()
        self.locationManager.startUpdatingLocation() 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

