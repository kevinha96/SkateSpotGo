//
//  NewSpotViewController.swift
//  FinalProject
//
//  Created by Kyle Wei on 8/1/16.
//  Copyright © 2016 wustl. All rights reserved.
//

import UIKit
import Firebase

class NewSpotViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var addressField: UITextField!
   
    @IBOutlet weak var typeField: UITextField!
    
    @IBOutlet weak var spotImage: UIImageView!
    
    var addressFromCoord = ""
    let map = SkateSpotController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        spotImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addProfileImage)))
        spotImage.isUserInteractionEnabled = true

        // Do any additional setup after loading the view.
        
        //address information from map
        if (addressFromCoord != "") {
            addressField.text = addressFromCoord
        }
    }
    
    func addProfileImage(){
        
        print("addImage")
        
        let picker = UIImagePickerController()
        picker.delegate = self
        
        present(picker, animated: true) {
            
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("picker cancel")
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let orgImage = info["UIImagePickerControllerOriginalImage"]{
            spotImage.image = orgImage as? UIImage
        }
        dismiss(animated: true, completion: nil)
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func registerToDatabase(_ spotName: String, imageURL: URL){
        
        //Store the name, username, and extra info in the FIRdatabase using the user id
        let ref = FIRDatabase.database().reference().child("Spots")
        
        let id = UserDefaults.standard.value(forKey: "userID_session") as! String
        
        let newData = ["Creator": id, "Name": self.nameField!.text!, "Rating" : 0, "Address" : self.addressField!.text!, "Type": self.typeField!.text!, "TotalScore" : 0,  "TotalRatings": 0, "imageURL" : imageURL.absoluteString] as [String : Any]
        
        print("New spot added")
        
        ref.child(spotName).setValue(newData)
        self.dismiss(animated: true, completion: nil)
        
        
    }
    

    
    @IBAction func backButton(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func addSpot(_ sender: AnyObject) {
        
        //check if fields filled and alert user if error
        if self.nameField.text! == "" || self.addressField.text! == "" || self.typeField.text! == "" || self.spotImage.image == UIImage(named: "Upload-image"){
            
            let alertcontroller = UIAlertController(title: "Empty Fields", message: "Please fill in all required fields to make an account", preferredStyle: .alert)
            let defaultaction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            alertcontroller.addAction(defaultaction)
            self.present(alertcontroller, animated: true, completion: nil)
            
        }else{

            let name = self.nameField!.text!
            
            let store = FIRStorage.storage().reference().child("Spot_Images").child(name + ".png")
            
            if let uploadData = UIImagePNGRepresentation(self.spotImage.image!){
                
                //write data
                store.put(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil{
                        print(error)
                        print ("ERROR")
                        return
                    }
                    
                    print(name)
                    self.registerToDatabase(name, imageURL: (metadata?.downloadURL())!)
                    print(metadata?.downloadURL())
                })
            }
            

            
            //registerToDatabase(nameField.text!)
            
            
        }
        
        
    }

        
    }

