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
    
    var recipeArray = [Recipe]()
    
    static let shared = DataService()
    
    func fetchRecipeWithQuery(queryText: String, completion: @escaping CompletionHandler) {
        recipeArray = []
        let url = "\(QUERY_URL)\(queryText)\(API_SECURITY_CREDENTIALS)"
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            if response.result.error == nil {
                guard let data = response.data else {return}
                
                do {
                    let json = try JSON(data: data)
                    self.parseJSON(json: json)
                    NotificationCenter.default.post(name: NOTIF_RECIPES_LOADED, object: nil)
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
    
    func parseJSON(json: JSON) {
        guard let hitsArray = json["hits"].array else {return}
        
        for item in hitsArray {
            guard let recipeDictionary = item["recipe"].dictionary else {return}
            guard let recipeName = recipeDictionary["label"]?.stringValue else {return}
            guard let recipeImageURL = recipeDictionary["image"]?.stringValue else {return}
            guard let recipeSource = recipeDictionary["source"]?.stringValue else {return}
            guard let recipeURL = recipeDictionary["url"]?.stringValue else {return}
            guard let recipeYield = recipeDictionary["yield"]?.intValue else {return}
            guard let recipeDietLabels = recipeDictionary["dietLabels"]?.arrayValue else {return}
            guard let recipeHealthLabels = recipeDictionary["healthLabels"]?.arrayValue else {return}
            guard let recipeIngredientLines = recipeDictionary["ingredientLines"]?.arrayValue else {return}
            guard let recipeCalories = recipeDictionary["calories"]?.doubleValue else {return}
            guard let recipeTotalDailyNutrientsDict = recipeDictionary["totalDaily"]?.dictionaryValue else {return}
            
            let newRecipe = Recipe(name: recipeName, source: recipeSource, imageURL: recipeImageURL, url: recipeURL, yield: recipeYield, dietLabels: recipeDietLabels, healthLabels: recipeHealthLabels, ingredientLines: recipeIngredientLines, calories: recipeCalories, totalDailyNutrients: recipeTotalDailyNutrientsDict)
            recipeArray.append(newRecipe)
            print(recipeImageURL)
        }
    }
}
