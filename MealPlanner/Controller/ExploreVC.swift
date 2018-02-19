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

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.hideKeyboardWhenTappedAround()
        
    }

    @IBAction func signOutTapped(_ sender: Any) {
        KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("ID removed fvrom keychain")
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "goToSignIn", sender: nil)
        print(Auth.auth().currentUser as Any)
    }
    
    @IBAction func searchBtnTapped(_ sender: Any) {
        guard let queryText = searchField.text, searchField.text != nil else {return}
        
        DispatchQueue.global(qos: .userInitiated).async {
            DataService.shared.fetchRecipeWithQuery(queryText: queryText) { (success) in
                //do stuff
            }
        }
        
    }
    
    @IBAction func microphoneTapped(_ sender: Any) {
    }
    
    @IBAction func filterTapped(_ sender: Any) {
    }
    
    
}

extension ExploreVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "recipeCell") as? RecipeCell else { return UITableViewCell() }
        return cell
    }
    
    
}

