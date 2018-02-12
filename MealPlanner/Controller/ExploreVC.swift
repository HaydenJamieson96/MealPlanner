//
//  ExploreVC.swift
//  MealPlanner
//
//  Created by Hayden Jamieson on 07/02/2018.
//  Copyright © 2018 Hayden Jamieson. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class ExploreVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func signOutTapped(_ sender: Any) {
        KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("ID removed fvrom keychain")
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "goToSignIn", sender: nil)
        print(Auth.auth().currentUser as Any)
    }
    

}

