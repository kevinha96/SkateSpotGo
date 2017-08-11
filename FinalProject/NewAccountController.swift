//
//  NewAccountController.swift
//  FinalProject
//
//  Created by Labuser on 7/24/16.
//  Copyright © 2016 wustl. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class NewAccountController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var usernameInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
    @IBOutlet weak var hometownInput: UITextField!
    @IBOutlet weak var skateFaveInput: UITextField!
    @IBOutlet weak var skillInput: UISegmentedControl!
    
    @IBOutlet weak var uploadImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        uploadImage.image = UIImage(named: "upload")
        
        uploadImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addProfileImage)))
        uploadImage.isUserInteractionEnabled = true
    }

    //present image picker when image is selected
    func addProfileImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        
        present(picker, animated: true) {

        }
    }
    
    //control cancellation of picker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //set upload image as picture that is picked
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let orgImage = info["UIImagePickerControllerOriginalImage"]{
            uploadImage.image = orgImage as? UIImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func registerToDatabase(_ user: String, imageURL: URL){
        
        //Store the name, username, and extra info in the FIRdatabase using the user id
        let ref = FIRDatabase.database().reference().child("Users")
        
        let newData = ["username": self.usernameInput!.text!, "hometown" : self.hometownInput!.text!, "full_name" : self.nameInput!.text!, "faveSpots": self.skateFaveInput!.text!,
                       "skillLevel" : self.skillInput.selectedSegmentIndex.description, "imageURL": imageURL.absoluteString]
        
        ref.child(user).setValue(newData)
        
        //send user to tab view-
        self.performSegue(withIdentifier: "newToTab", sender: self)

    }
    
    @IBAction func createAccountAction(_ sender: AnyObject) {
        
        //check if all required fields are filled and if not, then alert the user
        if self.nameInput.text! == "" || self.emailInput.text! == "" || self.usernameInput.text! == "" || self.passwordInput.text! == ""
        || self.uploadImage.image! == UIImage(named: "upload"){

            let alertcontroller = UIAlertController(title: "Empty Fields", message: "Please fill in all required fields to make an account", preferredStyle: .alert)
            let defaultaction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            alertcontroller.addAction(defaultaction)
            self.present(alertcontroller, animated: true, completion: nil)
            
        }else{
            
            //create a new user in the auth database
            FIRAuth.auth()?.createUser(withEmail: self.emailInput.text!, password: self.passwordInput.text!, completion: { (user, error) in
                
                if error == nil{
                    
                    let newUser = (user?.uid)!
                    
                    //save username and user id in nsuser defaults for use during session
                    UserDefaults.standard.setValue(self.usernameInput!.text, forKey: "username_session")
                    UserDefaults.standard.setValue(newUser, forKey: "userID_session")
                    
                    //Store the user's selected picture (if they selected one) in the Firebase storage
                    let store = FIRStorage.storage().reference().child("Profile_Images").child(newUser + ".png")
                        
                        if let uploadData = UIImagePNGRepresentation(self.uploadImage.image!){
                            
                            store.put(uploadData, metadata: nil, completion: { (metadata, error) in
                                if error != nil{
                                    print(error)
                                    return
                                }

                              self.registerToDatabase(newUser, imageURL: (metadata?.downloadURL())!)
                              print(metadata?.downloadURL())
                            })
                        }

                    
                }else{
                    
                    //Alert the user of firebase provided account creation error
                    let alertcontroller = UIAlertController(title: "Account Creation Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultaction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
                    alertcontroller.addAction(defaultaction)
                    self.present(alertcontroller, animated: true, completion: nil)
                    
                }
   
            })

            
        }
        
        
    }

}
