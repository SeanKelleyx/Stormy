//
//  ViewController.swift
//  Stormy
//
//  Created by Sean Kelley on 3/27/15.
//  Copyright (c) 2015 SeanKelley. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var precipLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var loadingView: UIView!
    
    private let apiKey = "4a7a86784dd76767baf4435021887aa1"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let baseURL = NSURL(string: "https://api.forecast.io/forecast/\(apiKey)/")
        let forecastURL = NSURL(string: "43.726596,-87.713287", relativeToURL: baseURL)
        let sharedSession = NSURLSession.sharedSession()
        let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(forecastURL!, completionHandler:
            {(location: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
                if(error == nil){
                    let dataObject = NSData(contentsOfURL: location)
                    let weatherDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataObject!, options: nil, error: nil) as NSDictionary
                    let currentWeather = Current(weatherDictionary: weatherDictionary)
                    self.loadCurrentToScreen(currentWeather)
                    self.loadingView.removeFromSuperview()
                }
        })
        downloadTask.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadCurrentToScreen(currentWeather: Current){
        iconImage.image = currentWeather.icon
        timeLabel.text = "At \(currentWeather.currentTime!) it is"
        tempLabel.text = "\(currentWeather.temperature)"
        humidityLabel.text = "\(Int(currentWeather.humidity * 100))%"
        precipLabel.text = "\(Int(currentWeather.precipProbability * 100))%"
        descriptionLabel.text = currentWeather.summary
    }


}

