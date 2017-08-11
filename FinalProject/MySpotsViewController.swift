//
//  MySpotsViewController.swift
//  SSG
//
//  Created by Kyle Wei on 7/26/16.
//  Copyright © 2016 Kyle Wei. All rights reserved.
//

import UIKit
import Firebase

class Spot {
    
    var name: String = ""
    var rating: Double = 0.0
    var distance: Double = 0.0
    var type:String = ""
    var totalRatings: Int = 1
    var totalScore: Double = 0.0
    var address: String = ""
    
    
    
    init(name:String, rating: Double, distance: Double, type:String, totalRatings: Int, totalScore: Double, address: String) {
        self.name = name
        self.rating = rating
        self.distance = distance
        self.type = type
        self.totalScore = totalScore
        self.totalRatings = totalRatings
        self.address = address
    }
    
}

class SpotCell: UITableViewCell {
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
}


class MySpotsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
   
    
    @IBOutlet weak var spotTable: UITableView!
    
    @IBOutlet weak var sortSelect: UISegmentedControl!
    
    
    var spotArray:[Spot] = []
    
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
                if (creator == id) {
                    let theName = entry.1.value(forKey: "Name") as? String
                    //let theRating = 2.0
                    let theTotalScore = entry.1.value(forKey: "TotalScore") as? Double
                    let theTotalRatings = entry.1.value(forKey: "TotalRatings") as? Int
                    
                    let types = entry.1.value(forKey: "Type") as? String
                    let address = entry.1.value(forKey: "Address") as? String
                    print(theName)
                    let theRating = theTotalScore! / Double (theTotalRatings!)
                    
                    let spot1 = Spot(name: theName!, rating: theRating, distance: 0.5, type: types!, totalRatings: theTotalRatings!, totalScore: theTotalScore!,
                        address: address!)
                    self.spotArray.append(spot1)
                }
            }
            self.spotTable.reloadData()
            }
 
        })

        sortByName()

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
        spotArray.sort() { $0.distance < $1.distance }
        spotTable.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spotArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell    {

        let myCell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SpotCell
        
        myCell.selectionStyle = UITableViewCellSelectionStyle.none
        
        myCell.textLabel?.textAlignment = .left
        myCell.detailTextLabel?.textAlignment = .right
        myCell.accessoryType = .disclosureIndicator
        
        //set cell values accordinf to spotArray
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

        //store info to send to detail view
        UserDefaults.standard.setValue(selectedSpot.name, forKey: "spot_name")
        UserDefaults.standard.setValue(selectedSpot.rating, forKey: "spot_rating")
        UserDefaults.standard.setValue(selectedSpot.type, forKey: "spot_type")
        UserDefaults.standard.setValue(selectedSpot.address, forKey: "spot_address")
        UserDefaults.standard.setValue(selectedSpot.totalRatings, forKey: "spot_totalRatings")
        UserDefaults.standard.setValue(selectedSpot.totalScore, forKey: "spot_totalScore")
        
        
        print("Selected a spot:  \(selectedSpot.name)")
        performSegue(withIdentifier: "myToSpot", sender: self)

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
  
}





