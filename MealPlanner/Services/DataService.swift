//
//  DataService.swift
//  MealPlanner
//
//  Created by Hayden Jamieson on 15/02/2018.
//  Copyright © 2018 Hayden Jamieson. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class DataService {
    
    private init() {}
    
    static let shared = DataService()
    
    func fetchRecipeWithQuery(queryText: String, completion: @escaping CompletionHandler) {
        let url = "\(QUERY_URL)\(queryText)\(API_SECURITY_CREDENTIALS)"
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            if response.result.error == nil {
                guard let data = response.data else {return}
                
                do {
                    let json = try JSON(data: data)
                    print(json)
                    completion(true)
                } catch {
                     debugPrint(error.localizedDescription)
                }
            } else {
                debugPrint(response.result.error as Any)
                completion(false)
            }
        }
    }
}
