//
//  LoginViewController.swift
//  MoodSwings
//
//  Created by Sandeep Hasrajani on 7/22/17.
//  Copyright © 2017 Sandeep Hasrajani. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        loginButton.center = self.view.center
        loginButton.delegate = self
        self.view.addSubview(loginButton)
        //self.login()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.login()
    }

    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        print("LOGGED IN")
        if (result.token != nil) {
            self.performSegue(withIdentifier: "moodsTransition", sender: self)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("logged out")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "moodsTransition") {
            let destinationViewController = segue.destination as! MoodsViewController
            
            // if you don't call .view, this destination view controller will be nil because the view hasn't loaded yet. Calling .view forces you
            // the view to load.
            let _ = destinationViewController.view
            destinationViewController.moodsCollectionView.reloadData()
        }
    }
    
    func login() {
        if ((FBSDKAccessToken.current()) != nil) {
            self.performSegue(withIdentifier: "moodsTransition", sender: self)
        }
    }
}
