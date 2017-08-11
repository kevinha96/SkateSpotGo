//
//  MyProfileController.swift
//  FinalProject
//
//  Created by Labuser on 7/25/16.
//  Copyright © 2016 wustl. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class FavoriteCell: UITableViewCell{
    @IBOutlet weak var spot: UILabel!
}


class MyProfileController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var Favorites = [String]()
    
    @IBOutlet weak var userFavorites: UITableView!
    
    @IBOutlet weak var hometown: UILabel!
    @IBOutlet weak var level: UILabel!
    @IBOutlet weak var skateInfo: UILabel!
    @IBOutlet weak var nickname: UILabel!
    
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var username: UILabel!
    
    @IBAction func logout(_ sender: AnyObject) {
        
        UserDefaults.standard.setValue("", forKey: "username_session")
        UserDefaults.standard.setValue("", forKey: "userID_session")
        
        performSegue(withIdentifier: "logout", sender: self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.viewDidLoad()
        self.userFavorites.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userFavorites.delegate = self
        userFavorites.dataSource = self
        
        let id = UserDefaults.standard.value(forKey: "userID_session") as! String
        let ref = FIRDatabase.database().reference().child("Users")

        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {

        //Get User info to fill out profile
        ref.observe(FIRDataEventType.value, with: { (snapshot) in
            let info = snapshot.value as! [String : NSDictionary]
            
            let x = info[id]!
            self.Favorites = []
            let faves = UserDefaults.standard
            if let arr = faves.array(forKey: id){
                for x in arr{
                    print(x)
                    self.Favorites.append(x as! String)
                }
                
            }else{
                self.Favorites = []
            }
           
            self.userFavorites.reloadData()
            
            print(self.Favorites.count)
            
            if x.value(forKey: "hometown") as? String != ""{
                self.hometown.text = x.value(forKey: "hometown") as? String
            }else{
                self.hometown.text = "N/A"
            }
            
            let type = x.value(forKey: "faveSpots") as? String
            if type != ""{
                self.skateInfo.text = type
            }else{
                self.skateInfo.text = "N/A"
            }
            
            var lev = ""
            
            switch x.value(forKey: "skillLevel") as! String{
                case "0": lev="Beginner"
                case "1": lev = "Intermediate"
                case "2": lev = "Advanced"
                case "3": lev = "Pro"
                default: lev = "N/A"
            }
            
            self.level.text = lev

            self.username.text = x.value(forKey: "full_name") as? String
            
            self.nickname.text = x.value(forKey: "username") as? String
            
            if let profileImageURL = x.value(forKey: "imageURL"){
                let url = URL(string:profileImageURL as! String)
                URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                    if error != nil{
                        print("downloadError")
                    }
                    
                    DispatchQueue.main.async(execute: {
                        self.userImage.image = UIImage(data: data!)
                    })
                }).resume()
            }else{
                print("problem with image url")
            }
        })
            
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return Favorites.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let ref = FIRDatabase.database().reference().child("Spots")
        
        ref.observe(FIRDataEventType.value, with: { (snapshot) in
            //let info = snapshot.value as! [String : NSDictionary]
            
            let info = snapshot.value as! [String : NSDictionary]
            if let spot = info[self.Favorites[(indexPath as NSIndexPath).row]]{
                UserDefaults.standard.setValue(spot.value(forKey: "Name")!, forKey: "spot_name")
                UserDefaults.standard.setValue(spot.value(forKey: "Rating")!, forKey: "spot_rating")
                UserDefaults.standard.setValue(spot.value(forKey: "Type")!, forKey: "spot_type")
                UserDefaults.standard.setValue(spot.value(forKey: "Address")!, forKey: "spot_address")
            }
        })
        
        performSegue(withIdentifier: "faveToSpot", sender: self)
   
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = userFavorites.dequeueReusableCell(withIdentifier: "Fave", for: indexPath) as! FavoriteCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.spot.text = Favorites[(indexPath as NSIndexPath).row]
        
        return cell
        
    }
    
}
