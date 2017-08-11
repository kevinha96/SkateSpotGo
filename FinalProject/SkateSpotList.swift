//
//  MySpotsViewController.swift
//  SSG
//
//  Created by Kyle Wei on 7/26/16.
//  Copyright © 2016 Kyle Wei. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation


class SkateSpotList: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var spotTable: UITableView!
    
    @IBOutlet weak var sortSelect: UISegmentedControl!
    
    var spotArray:[Spot] = []
    
    var geocoder = CLGeocoder()
    let map = SkateSpotController()
    let locationManager = CLLocationManager()
    var currCoord = CLLocation(latitude: 0, longitude: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spotTable.dataSource = self
        spotTable.delegate = self
        
        let id = UserDefaults.standard.value(forKey: "userID_session") as! String
        
        let ref = FIRDatabase.database().reference().child("Spots")
        
        ref.observe(FIRDataEventType.value, with: { (snapshot) in
            
            if let info = snapshot.value as? [String : NSDictionary]{
            self.spotArray = []
            for entry in info{
                let creator = entry.1.value(forKey: "Creator") as! String
                let theName = entry.1.value(forKey: "Name") as? String
                
                let theTotalScore = entry.1.value(forKey: "TotalScore") as? Double
                let theTotalRatings = entry.1.value(forKey: "TotalRatings") as? Int
                
                var type1 = ""
                if let types = entry.1.value(forKey: "Type") as? String{
                    type1 = types
                }else{
                    type1 = ""
                }
                
                var add = ""
                if let address = entry.1.value(forKey: "Address") as? String{
                    add = address
                }else{
                    add = ""
                }
                
                //
                
                
                let theRating = theTotalScore! / Double (theTotalRatings!)
                
                
                let spot1 = Spot(name: theName!, rating: theRating, distance: 0.5, type: type1, totalRatings: theTotalRatings!, totalScore: theTotalScore!, address: add)
                
                self.spotArray.append(spot1)
                
            }
            }
            self.sortByName()
            
            self.spotTable.reloadData()
            
        })
        
        // Do any additional setup after loading the view, typically from a nib.
//        arrangeDistance()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sortByName() {
        spotArray.sort() { $0.name < $1.name }
        spotTable.reloadData()
        
    }
    func sortByRating() {
        spotArray.sort() { $0.rating > $1.rating }
        spotTable.reloadData()
    }
    
    func sortByDistance(){
        
        //forward geocoding
        for spot in spotArray {
            geocoder.geocodeAddressString(spot.address, completionHandler: {(placemarks, error) ->  Void in
                if((error) != nil){
                    print("Error", error)
                }
                if let placemark = placemarks?.first {
                    let coord = placemark.location!
                    spot.distance = coord.distance(from: self.currCoord)
                    
                }
            })
        }
        spotArray.sort() { $0.distance < $1.distance }
        spotTable.reloadData()
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spotArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell    {
        //let myCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: nil) as! SpotCell
        
        let myCell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SpotCell
        myCell.selectionStyle = UITableViewCellSelectionStyle.none
        
        myCell.textLabel?.textAlignment = .left
        myCell.detailTextLabel?.textAlignment = .right
        myCell.accessoryType = .disclosureIndicator
        
        //myCell.textLabel!.text = spotArray[indexPath.row].name
        
        print((indexPath as NSIndexPath).row)
        print(spotArray[(indexPath as NSIndexPath).row].name)
        
        //myCell.detailTextLabel?.text = String ("\(spotArray[indexPath.row].rating) / 5.0 \r\n \(spotArray[indexPath.row].distance) mi")
        let rawRating = spotArray[(indexPath as NSIndexPath).row].rating
        let roundedRating = Double(round(10*rawRating)/10)
        myCell.ratingLabel.text = String("\(roundedRating) / 5.0")
        myCell.distanceLabel.text = String("\(spotArray[(indexPath as NSIndexPath).row].distance) mi")
        
        myCell.typeLabel.text = spotArray[(indexPath as NSIndexPath).row].type
        
        myCell.nameLabel.text = spotArray[(indexPath as NSIndexPath).row].name
        
        return myCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let selectedSpot = spotArray[(indexPath as NSIndexPath).row]
        
        let rawRating = selectedSpot.rating
        let roundedRating = Double(round(10*rawRating)/10)
        
        UserDefaults.standard.setValue(selectedSpot.name, forKey: "spot_name")
        UserDefaults.standard.setValue(selectedSpot.rating, forKey: "spot_rating")
        UserDefaults.standard.setValue(selectedSpot.type, forKey: "spot_type")
        UserDefaults.standard.setValue(selectedSpot.address, forKey: "spot_address")
        UserDefaults.standard.setValue(selectedSpot.totalRatings, forKey: "spot_totalRatings")
        UserDefaults.standard.setValue(selectedSpot.totalScore, forKey: "spot_totalScore")
        
        print("Selected a spot:  \(selectedSpot.name)")
        performSegue(withIdentifier: "listToSpot", sender: self)
    }
    
    
    @IBAction func sortBy(_ sender: AnyObject) {
        switch sortSelect.selectedSegmentIndex {
        case 0:
            sortByName()
        case 1:
            sortByRating()
        case 2:
            sortByDistance()
        default:
            sortByName()
        }
        
    }
    
    //for current location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currCoord = manager.location!
    }
    
    //arrange distances
    func arrangeDistance () {
        for spot in spotArray {
            //forwards geocoding
            geocoder.geocodeAddressString(spot.address, completionHandler: {(placemarks, error) ->  Void in
                if((error) != nil){
                    print("Error", error)
                }
                if let placemark = placemarks?.first {
                    let coord = placemark.location!
                    spot.distance = coord.distance(from: self.currCoord)
                    
                }
            })
        }
    }
}




