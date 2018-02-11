//
//  LoginVC.swift
//  MealPlanner
//
//  Created by Hayden Jamieson on 08/02/2018.
//  Copyright © 2018 Hayden Jamieson. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import GoogleSignIn
import SwiftKeychainWrapper

class LoginVC: UIViewController , GIDSignInUIDelegate {

    @IBOutlet weak var emailField: RoundedTextField!
    @IBOutlet weak var passwordField: RoundedTextField!
    @IBOutlet weak var gmailSignInBtn: GIDSignInButton!
    @IBOutlet weak var fbLoginBtn: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.delegate = self
        passwordField.delegate = self
        gmailSignInBtn.style = .wide
        gmailSignInBtn.colorScheme = .light
        
    
        let layoutConstraintsArr = fbLoginBtn.constraints
        for lc in layoutConstraintsArr {
            if lc.constant == 28 || lc.constant == 30 {
                lc.isActive = false
                break
            } else if lc.constant == 315 {
                lc.isActive = true
            }
        }
        
        self.hideKeyboardWhenTappedAround()
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            performSegue(withIdentifier: "goToExplore", sender: nil)
        }
        
    }
    
    @IBAction func signInTapped(_ sender: Any) {
        guard let email = emailField.text, let password = passwordField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error == nil {
                print("Email user authenticated with Firebase")
                guard let user = user else {return}
                self.completeSignIn(id: user.uid)
            } else {
                Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                    if password.count <= 5 {
                        self.showError(withTitle: "Password too short", andMessage: "Password must be longer than 5 characters")
                    } else if error != nil {
                        self.showError(withTitle: "Firebase Error", andMessage: "Unable to authenticate with Firebase using email")
                    } else {
                        print("Successfully authenticated with Firebase")
                        guard let user = user else {return}
                        self.completeSignIn(id: user.uid)
                    }
                })
            }
        }
    }
    
   
    @IBAction func gmailBtnTapped(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn();
    }
    
    @IBAction func facebookBtnTapped(_ sender: Any) {
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                self.showError(withTitle: "Facebook Error", andMessage: "Unable to authenticate with Facebook")
            } else if result?.isCancelled == true {
                print("User cancelled Facebook authentication")
            } else {
                print("Successfully authenticated with Facebook")
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
        }
    }
    
    func firebaseAuth(_ credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil {
                print(error)
                self.showError(withTitle: "Firebase Error", andMessage: "Unable to authenticate with Firebase")
                return
            }
            print("Sucessfully authenticated with Firebase")
            guard let user = user else {return}
            self.completeSignIn(id: user.uid)
        }
    }
    
    func completeSignIn(id: String) {
        KeychainWrapper.standard.set(id, forKey: KEY_UID)
        performSegue(withIdentifier: "goToExplore", sender: nil)
    }
    
}

extension LoginVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.placeholder = nil
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == emailField {
            textField.attributedPlaceholder = NSAttributedString(string: "Enter email", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        } else if textField == passwordField {
             textField.attributedPlaceholder = NSAttributedString(string: "Enter password", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
}
