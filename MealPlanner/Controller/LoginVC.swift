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

class LoginVC: UIViewController , GIDSignInUIDelegate, FBSDKLoginButtonDelegate {

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
        fbLoginBtn.delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
    
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
    }
    
    /**
        This function handles our auto sign-in feature. If the Keychain finds a key for this device, we automatically navigate to ExploreVC.
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            performSegue(withIdentifier: "goToExplore", sender: nil)
        }
        
    }
    
    // MARK: Email/password login
    
    /**
        This function handles our authentication using email and password. We safely unwrap the email/password text.
        We call our Alamofire signIn function, passing our unwrapped email/password values as arguments.
        We handle any error cases, and if the user already exists in Firebase database, we call our completeSignIn function passing in the user info to sign them in.
        If there is no user in the database with that email identifier, we simply create a new user and call our completeSignIn function.
     */
    @IBAction func signInTapped(_ sender: Any) {
        guard let email = emailField.text, let password = passwordField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error == nil {
                print("Email user authenticated with Firebase")
                guard let user = user else {return}
                self.completeSignIn(id: user.uid, withVC: self)
            } else {
                Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                    if password.count <= 5 {
                        self.showError(withTitle: "Password too short", andMessage: "Password must be longer than 5 characters")
                    } else if error != nil {
                        self.showError(withTitle: "Firebase Error", andMessage: "Unable to authenticate with Firebase using email")
                    } else {
                        print("Successfully authenticated with Firebase")
                        guard let user = user else {return}
                        self.completeSignIn(id: user.uid, withVC: self)
                    }
                })
            }
        }
    }
    
    // MARK: Facebook Login
    
    /**
        Delegate method for signing in. We grab the users credentials using the Firebase Facebook Auth provider, using the access token provided by the Facebook API.
        We then call our Firebase Authentication handler using the Facebook credential we just created.
     */
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        print("Successfully authenticated with Facebook")
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        self.firebaseAuth(credential, withVC: self)

    }
    
    /**
        This delegate function is called when the Facebook logout button is pressed (automatically changes once logged in)
        Remove the Key from the Keychain, sign out of Firebase.
    */
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("ID removed fvrom keychain")
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out :%@", signOutError)
        }
        
    }
    
    // MARK: Firebase Auth
    
    /**
        This function handles authenticating users with Firebase for Facebook and Google sign-in.
        We grab the current user, if they already exist, we try to link them with the other providers. This is for when a user is trying to sign in using more than one provider, e.g. initially used Facebook, then wanted to use Google. The email is already used in the back end, so we link the accounts.
        We sign the user in using the credential provided and link that user with other providers. Call the completeSignIn function once done.
     
        - Parameters:
            - credential: The authentication credential used, e.g. Facebook credential
            - vc: The view controller used to navigate, this is due to Google's delegate methods being contained in the App Delegate. It throws an error from the AppD as it cannot find the segue to navigate to ExploreVC.
    */
    func firebaseAuth(_ credential: AuthCredential, withVC vc: UIViewController) {
        
        let currentUser = Auth.auth().currentUser
        
        if currentUser != nil {
            Auth.auth().currentUser?.link(with: credential, completion: { (user, error) in
                if user != nil && error == nil {
                    print("Linked accounts")
                    guard let user = user else {return}
                    self.completeSignIn(id: user.uid, withVC: vc)
                }
            })
        } else {
            Auth.auth().signIn(with: credential) { (user, error) in
                if error != nil {
                    print(error!)
                    self.showError(withTitle: "Firebase Error", andMessage: "Unable to authenticate with Firebase")
                    return
                }
                print("Sucessfully authenticated with Firebase")
                guard let user = user else {return}
                user.link(with: credential, completion: { (user, error) in
                    print("Linked user to credential")
                })
                self.completeSignIn(id: user.uid, withVC: vc)
            }
        }
        
        
    }
    
    // MARK: Keychain auto-sign in handling
    
    /**
        This function handles adding the users key to the Keychain wrapper for auto log-in.
        Navigate to ExploreVC.
    */
    func completeSignIn(id: String, withVC vc: UIViewController) {
        KeychainWrapper.standard.set(id, forKey: KEY_UID)
        DispatchQueue.main.async {
            vc.performSegue(withIdentifier: "goToExplore", sender: nil)
        }
        
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
