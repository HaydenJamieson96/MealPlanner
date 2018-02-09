//
//  DismissKeyboardWhenTappedAnywhere.swift
//  MealPlanner
//
//  Created by Hayden Jamieson on 09/02/2018.
//  Copyright © 2018 Hayden Jamieson. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
}
