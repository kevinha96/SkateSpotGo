//
//  SkateSpotViewController.swift
//  FinalProject
//
//  Created by Kyle Wei on 7/26/16.
//  Copyright © 2016 wustl. All rights reserved.
//

import UIKit
import Firebase

class SkateSpotViewController: UIViewController {

    @IBOutlet weak var DeleteButton: UIButton!
    @IBOutlet weak var FaveButton: UIButton!
    
    
    
    @IBOutlet weak var reviewNumber: UITextField!
    
    @IBOutlet weak var spotImage: UIImageView!
    @IBOutlet weak var navTitleBar: UINavigationItem!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet weak var typeLabel: UILabel!
    var spotName:String!
    var spotRating: Double!
    var spotType: String!
    var spotAddress: String!
    var totalScore: Double!
    var totalRatings: Int!
    
    @IBAction func deleteSpot(_ sender: AnyObject) {
        
        
        let user = UserDefaults.standard.value(forKey: "userID_session") as! String
        
        let faves = UserDefaults.standard
        
        var arr = faves.array(forKey: user)
        var remove = -1
        for x in 0 ..< arr!.count{
            if arr![x] as! String == self.spotName{
                remove = x
            }
        }
        
        arr!.remove(at: remove)
        faves.setValue(arr, forKey: user)
        
        FaveButton.isHidden = false
        DeleteButton.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    

    @IBAction func createReview(_ sender: AnyObject) {
        
        if self.reviewNumber.text == "1" || self.reviewNumber.text == "2" ||
          reviewNumber.text == "3" || reviewNumber.text == "4" || reviewNumber.text == "5" || reviewNumber.text == "0"{
            let ref = FIRDatabase.database().reference().child("Spots")
            //var newTotal = 0
            //var newScore = 0
            //var newRating = 0
            let ratingInput = Int(self.reviewNumber.text!)!
            print ("Spot is getting rated")
            
           
            
            
            print ("The total ratings: \(totalRatings)")
            
            let newTotal = totalRatings + 1
            let newScore:Double = Double(totalScore) + Double(ratingInput)
            let newRating = Double(newScore / Double(newTotal))
            
            //NSUserDefaults.standardUserDefaults().setValue(newTotal, forKey: "spot_totalRatings")
            //NSUserDefaults.standardUserDefaults().setValue(Double(newScore), forKey: "spot_totalScore")
            
            spotRating = newRating
            totalRatings = newTotal
            totalScore = newScore
            
            
            let roundedRating = Double(round(10*newRating)/10)
            
            ratingLabel.text = "Rating: \(roundedRating) / 5.0 (\(totalRatings) Ratings)"
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {

                ref.observe(FIRDataEventType.value, with: { (snapshot) in
                    let info = snapshot.value as! [String : NSDictionary]
                    let x = info[self.spotName]!
                    
                    /*
                    newTotal = x.valueForKey("TotalRatings") as! Int + 1
                    newScore = x.valueForKey("TotalScore") as! Int + Int(self.reviewNumber.text!)!
                    newRating = newScore / newTotal
                    */
                    
                    print("Spot: \(x.value(forKey: "Name"))")
                    print("Old Total: \(x.value(forKey: "TotalRatings"))")
                    print("Old Score: \(x.value(forKey: "TotalScore"))")
                    
                    print("newTotal:  \(newTotal)")
                    print("newScore:  \(newScore)")
                    print ("New Rating: \(newRating)")
                })
                DispatchQueue.main.async(execute: {
                    
                    print("Saving new data")
                    ref.child(self.spotName).child("TotalRatings").setValue(newTotal)
                    ref.child(self.spotName).child("TotalScore").setValue(newScore)
                    ref.child(self.spotName).child("Rating").setValue(newRating)
                })
            }
            
            
        }else{
            let alertcontroller = UIAlertController(title: "Review Error", message: "Choose a whole number between 0 and 5", preferredStyle: .alert)
            let defaultaction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            alertcontroller.addAction(defaultaction)
            self.present(alertcontroller, animated: true, completion: nil)
        }
        
        self.reloadInputViews()
    }
    
    @IBAction func addToFavorites(_ sender: AnyObject) {
        let user = UserDefaults.standard.value(forKey: "userID_session") as! String

        let faves = UserDefaults.standard
        
        if var arr = faves.array(forKey: user){
            arr.append(self.spotName)
            faves.setValue(arr, forKey: user)
        }else{
            var arr = [String]()
            arr.append(self.spotName)
            faves.setValue(arr, forKey: user)
        }
        
        FaveButton.isHidden = true
        DeleteButton.isHidden = false
    }


    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        
        DeleteButton.isHidden = true
        
        spotName = UserDefaults.standard.value(forKey: "spot_name") as? String
        
        spotRating = UserDefaults.standard.value(forKey: "spot_rating") as? Double
        spotType = UserDefaults.standard.value(forKey: "spot_type") as? String
        spotAddress = UserDefaults.standard.value(forKey: "spot_address") as? String
        
        totalScore = UserDefaults.standard.value(forKey: "spot_totalScore") as? Double
        totalRatings = UserDefaults.standard.value(forKey: "spot_totalRatings") as? Int
        
        navTitleBar.title = spotName
        
        
        let id = UserDefaults.standard.value(forKey: "userID_session") as! String
        let faves = UserDefaults.standard
        if let arr = faves.array(forKey: id){
            for x in arr{
                if x as! String == spotName{
                    DeleteButton.isHidden = false
                    FaveButton.isHidden = true
                }
            }
            
        }else{
            
        }

        let roundedRating = Double(round(10*spotRating)/10)
        ratingLabel.text = "Rating: \(roundedRating) / 5.0 (\(totalRatings) Ratings)"
        addressLabel.text = "Address: \(spotAddress)"
        typeLabel.text = "Type: " + spotType
        
        navTitleBar.title = spotName
        
        let ref = FIRDatabase.database().reference().child("Spots")
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            
            //Get User info to fill out profile
            ref.observe(FIRDataEventType.value, with: { (snapshot) in
                let info = snapshot.value as! [String : NSDictionary]
                
                let theSpot = info[self.spotName]!

                if let profileImageURL = theSpot.value(forKey: "imageURL"){
                    let url = URL(string:profileImageURL as! String)
                    URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                        if error != nil{
                            print("downloadError")
                        }
                        
                        DispatchQueue.main.async(execute: {
                            self.spotImage.image = UIImage(data: data!)
                        })
                    }).resume()
                }else{
                    print("problem with image url")
                }
            })
            
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButton(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
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
