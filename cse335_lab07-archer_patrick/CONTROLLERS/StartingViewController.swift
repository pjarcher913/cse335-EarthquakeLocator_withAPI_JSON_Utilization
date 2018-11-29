//
//  StartingViewController.swift
//  cse335_lab07-archer_patrick
//
//  Created by Patrick Archer on 11/2/18.
//  Copyright © 2018 Patrick Archer - Self. All rights reserved.
//

/*
 NOTE: Add http-query-related information entries to Info.plist
 These entries/rows are:
 
 //...
 
 */

import UIKit
import Foundation
import CoreLocation

class StartingViewController: UIViewController {
    
    // textfield for user to enter desired zip code
    @IBOutlet weak var textfield_zipCode: UITextField!
    
    // textfield for user to enter desired country
    @IBOutlet weak var textfield_country: UITextField!
    
    // handles what happens when user presses the "Help" bar button
    @IBAction func barbutton_help(_ sender: UIBarButtonItem) {
        print("Executing handler for barbutton_help request") // debug
        //...
        
    }
    
    // handles what happens when user presses "SUBMIT" button to retrieve earthquake info
    @IBAction func button_submit(_ sender: UIButton) {
        // make asynchronous call to API
        DispatchQueue.main.async(execute: {
            print("Executing button_submit() via async main queue") // debug
            self.retrieveData()
        })
        //self.retrieveData() // debug
    }
    
    // textbox to display retrieved earthquake info
    @IBOutlet weak var textbox_earthquakeInfo: UITextView!
    
    // labels displaying Geonames.org-supplied location data via API call
    @IBOutlet weak var label_apiLat: UILabel!
    @IBOutlet weak var label_apiLon: UILabel!
    
    /**********************************/

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // set initial value for labels and text boxes
        self.textbox_earthquakeInfo.text = ""
        self.label_apiLat.text = ""
        self.label_apiLon.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /**********************************/

    // pulls data from Geonames.org API, parses it, and displays results to user
    func retrieveData ()
    {
        print("Executing retrieveData()")   // debug
        
        let userZipCode = self.textfield_zipCode.text
        let userCountry = self.textfield_country.text
        
        // we must first get the lat/lon coordinates for the location, then use them to get the earthquake info
        
        // create API call URL
        let urlAsString = "http://api.geonames.org/postalCodeLookupJSON?postalcode="+userZipCode!+"&country="+userCountry!+"&username=pjarcher"
        
        // configure API url and submit query request
        let url = URL(string: urlAsString)!
        let urlSession = URLSession.shared
        print("URL STRING SENT TO API: </ \(url) />")  // debug
        //print(url)  // debug
        
        print("About to exec jsonQuery")   // debug
        
        // store returned {JSON} query and catch errors
        let jsonQuery = urlSession.dataTask(with: url, completionHandler: { data, response, error -> Void in
            if (error != nil) {
                print(error!.localizedDescription)
            }
            var err: NSError?
            
            var jsonResult = (try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
            if (err != nil) {
                print("JSON Error \(err!.localizedDescription)")
            }
            
            print(jsonResult)   // debug
            
            // now parse retrieved JSON data and organize dictionaries/objects/arrays
            
            // store initial object ["postalcodes"] as an array
            let postalCodes:NSArray = jsonResult["postalcodes"] as! NSArray
            print(postalCodes) // debug
            
            // postalCodes[0] == the first returned results corresponding to the submitted zip code & country
            let locationData = postalCodes[0] as? [String: AnyObject]
            print(locationData?["placeName"]!)  // debug, might not need unwrap on [""]
            
            // parse locationData object for lat/lng coordinates and store them as var:Double
            let lng: Double = (locationData!["lng"] as? NSNumber)!.doubleValue
            let lat: Double = (locationData!["lat"] as? NSNumber)!.doubleValue
            print(lat)  // debug
            print(lng)  // debug
            
            DispatchQueue.main.async {
                // update labels to show user the location's corresponding lat/lon coords
                self.label_apiLat.text = String(lat)
                self.label_apiLon.text = String(lng)
                
                /*// execute getEarthquakeInfo() to find info around these coords
                self.getEarthquakeInfo(lat: lat, lon: lng)*/
            }
            
            // execute getEarthquakeInfo() to find info around these coords
            self.getEarthquakeInfo(lat: lat, lon: lng)
            
        })
        
        jsonQuery.resume()
        
    }
    
    // using lat/lon values, get earthquake info for a slightly larger radius around the passed lat/lon values
    func getEarthquakeInfo (lat:Double, lon:Double)
    {
        print("Executing getEarthquakeInfo()")   // debug
        
        /*
         URL:
         api.geonames.org/earthquakesJSON?
         
         Parameters:
         north,south,east,west : coordinates of bounding box
         callback : name of javascript function (optional parameter)
         date : date of earthquakes 'yyyy-MM-dd', optional parameter, earthquakes older or equal the given date sorted by date,magnitude
         minMagnitude : minimal magnitude, optional parameter
         maxRows : maximal number of rows returned (default = 10)
         
         Result : returns a list of earthquakes, ordered by magnitude
         
         Example http://api.geonames.org/earthquakesJSON?north=44.1&south=-9.9&east=-22.4&west=55.2&username=demo
         */
        
        // create north, south, east, west bound region
        let northBoundary = lat + 10.0
        let southBoundary = lat - 10.0
        let eastBoundary = lon + 10.0
        let westBoundary = lon - 10.0
        
        // create API call URL
        let urlP1 = "http://api.geonames.org/earthquakesJSON?"
        let urlP2 = "north="+String(northBoundary)
        let urlP3 = "&south="+String(southBoundary)
        let urlP4 = "&east="+String(eastBoundary)
        let urlP5 = "&west="+String(westBoundary)
        let urlP6 = "&maxRows=3&username=pjarcher"
        let urlAsString = urlP1+urlP2+urlP3+urlP4+urlP5+urlP6
        
        //let urlAsString = "http://api.geonames.org/earthquakesJSON?north="+northBoundary+"&south="+southBoundary+"&east="+eastBoundary+"&west="+westBoundary+"&maxRows=5+&username=pjarcher"
        
        /*
         "http://api.geonames.org/earthquakesJSON?
         north="+northBoundary
         +"&south="+southBoundary
         +"&east="+eastBoundary
         +"&west="+westBoundary
         +"&maxRows=5+&username=pjarcher"
         */
        
        // "http://api.geonames.org/postalCodeLookupJSON?postalcode="+userZipCode!+"&country="+userCountry!+"&username=pjarcher"
        
        // configure API url and submit query request
        let url = URL(string: urlAsString)!
        let urlSession = URLSession.shared
        print("URL STRING SENT TO API: </ \(url) />")  // debug
        //print(url)  // debug
        
        print("About to exec jsonQuery")   // debug
        
        // store returned {JSON} query and catch errors
        let jsonQuery = urlSession.dataTask(with: url, completionHandler: { data, response, error -> Void in
            if (error != nil) {
                print(error!.localizedDescription)
            }
            var err: NSError?
            
            var jsonResult = (try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
            if (err != nil) {
                print("JSON Error \(err!.localizedDescription)")
            }
            
            print(jsonResult)   // debug
            
            // now parse retrieved JSON data and organize dictionaries/objects/arrays
            
            let earthquakes:NSArray = jsonResult["earthquakes"] as! NSArray
            print(earthquakes)  // debug
            
            // create string of what will be displayed to user
            var completeEQinfo:String = ""
            
            let eqInfo = earthquakes[0] as! [String:AnyObject]
            print(eqInfo)   // debug
            
            let temptime = eqInfo["datetime"] as? String
            let templat = eqInfo["lat"] as? Double
            let templng = eqInfo["lng"] as? Double
            let tempmag = eqInfo["magnitude"] as? Double
            
            let masterString = "\n\nDateTime: "+temptime!+"\nMagnitude: "+String(tempmag!)+"\nLongitude: "+String(templng!)+"\nLatitude: "+String(templat!)
            print(masterString) // debug
            
            DispatchQueue.main.async {
                // update text box with EQ info
                self.textbox_earthquakeInfo.text = masterString
            }
            
            //self.textbox_earthquakeInfo.text = masterString
            
            /*print("DateTime: "+temptime!)    // debug
            print("Latitude: "+String(templat!)) // debug
            print("Longitude: "+String(templng!))    // debug
            print("Magnitude: "+String(tempmag!))    // debug*/
            
            
            
            
            
            
            
            //let eqInfo = earthquakes[0] as! [String:AnyObject]
            
            /*for i in 0..<earthquakes.count
            {
                //var tempDateTime = earthquakes[i] as? [String:AnyObject]
                var tempEQ = earthquakes[i] as! [String:AnyObject]
                var tempDateTime = tempEQ["datetime"] as? String
                var tempLat = tempEQ["lat"] as? String
                var tempLon = tempEQ["lng"] as? String
                var tempMag = tempEQ["magnitude"] as? String
                
                print("EQ Info = "+tempDateTime!+"\n"+tempLat!+"\n"+tempLon!+"\n"+tempMag!+"\n") // debug
                
                
                
                //completeEQinfo = completeEQinfo+tempEQ["datetime"]+tempEQ["lat"]+tempEQ["lng"]+tempEQ["magnitude"]
                //completeEQinfo = completeEQinfo.append(tempDateTime)
                
            }*/
            
            
            
            
            
            
            
            
            /*// store initial object ["postalcodes"] as an array
            let postalCodes:NSArray = jsonResult["postalcodes"] as! NSArray
            print(postalCodes) // debug
            
            // postalCodes[0] == the first returned results corresponding to the submitted zip code & country
            let locationData = postalCodes[0] as? [String: AnyObject]
            print(locationData?["placeName"]!)  // debug, might not need unwrap on [""]
            
            // parse locationData object for lat/lng coordinates and store them as var:Double
            let lng: Double = (locationData!["lng"] as? NSNumber)!.doubleValue
            let lat: Double = (locationData!["lat"] as? NSNumber)!.doubleValue
            print(lat)  // debug
            print(lng)  // debug
            
            DispatchQueue.main.async {
                // update labels to show user the location's corresponding lat/lon coords
                self.label_apiLat.text = String(lat)
                self.label_apiLon.text = String(lng)
                
                // execute getEarthquakeInfo() to find info around these coords
                self.getEarthquakeInfo(lat: lat, lon: lng)
            }*/
        })
        
        jsonQuery.resume()
        
    }
    
}












