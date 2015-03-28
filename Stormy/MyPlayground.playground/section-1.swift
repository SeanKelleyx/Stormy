// Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

let apiKey = "4a7a86784dd76767baf4435021887aa1"
let baseURL = NSURL(string: "https://api.forecast.io/forecast/\(apiKey)/")
let forecastURL = NSURL(string: "43.726596,-87.713287", relativeToURL: baseURL!)
forecastURL!
