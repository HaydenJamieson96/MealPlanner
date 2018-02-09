//
//  ErrorController.swift
//  MealPlanner
//
//  Created by Hayden Jamieson on 09/02/2018.
//  Copyright © 2018 Hayden Jamieson. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showError(withTitle title: String, andMessage message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    }
}
