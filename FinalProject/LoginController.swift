//
//  File.swift
//  FinalProject
//
//  Created by Labuser on 7/22/16.
//  Copyright © 2016 wustl. All rights reserved.
//

import Foundation
import UIKit

import Firebase

class LoginController: UIViewController{

    @IBOutlet weak var userInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func loginAction(_ sender: AnyObject) {
        
        //test if user has filled in fields
        if self.userInput.text == "" || self.passwordInput.text == ""{
            
            //alert if empty field
            let alertcontroller = UIAlertController(title: "Empty Field", message: "Please fill in both email and password", preferredStyle: .alert)
            let defaultaction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            alertcontroller.addAction(defaultaction)
            self.present(alertcontroller, animated: true, completion: nil)
        }
        
        //use firebase to authorize attempted login
        FIRAuth.auth()?.signIn(withEmail: self.userInput.text!, password: self.passwordInput.text!,completion: {(user, error)in

            if error == nil{
                //store user info in session variables
                UserDefaults.standard.setValue(self.userInput.text!, forKey: "user_session")
                UserDefaults.standard.setValue(user!.uid, forKey: "userID_session")

                self.performSegue(withIdentifier: "loginToTab", sender: self)

            }else{
                
                //alert user if error with login
                let alertcontroller = UIAlertController(title: "No such user", message: "Your username or password is incorrect...", preferredStyle: .alert)
                let defaultaction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
                alertcontroller.addAction(defaultaction)
                self.present(alertcontroller, animated: true, completion: nil)
 
            }
        })
        
        
    }

}
