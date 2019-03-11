//
//  LoginViewController.swift
//  Parstagram
//
//  Created by Russelle Pineda on 3/9/19.
//  Copyright © 2019 Russelle Pineda. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var userNameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    //loginSegue is identifier for loginView to FeedView
    
    //cannot segue directly from buttons!
    @IBAction func onSignInButton(_ sender: Any) {
        let username = userNameField.text!
        let password = passwordField.text!
        
        PFUser.logInWithUsername(inBackground: username, password: password) { (user, error) in
            if user != nil{
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
            else {
                print("Error with sign up!")
                print("Error: \(error?.localizedDescription)")
            }
        }
    }
    
    @IBAction func onSignUpButton(_ sender: Any) {
        
        //use Parse IOS documentation by searching google
        let user = PFUser()
        user.username = userNameField.text
        user.password = passwordField.text
        
        user.signUpInBackground { (success, error) in
            if success{
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
            else {
                print("Error with sign up!")
                print("Error: \(error?.localizedDescription)")
            }
 
        }
    }
    
    

}
