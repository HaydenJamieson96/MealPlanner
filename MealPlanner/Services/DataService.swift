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
    
    /**
        Fetches recipes from Edamam API using a query string parameter passed in to the request url, the query string is the type of recipe the user is searching for, e.g. Chicken.
        Uses Alamofire to create a GET request, giving a response in JSON format handled using the completion handler provided which is then wrapped in a JSON object using SwiftyJSON.
        Posts a recipes loaded notification once the web request has successfully completed and parsing of the JSON has completed. Our ExploreVC is acting as our observer and reloading the table view when it notices the notification has been fired off. 
        Call this function on a background thread asynchronously and do any UI updates on the main thread.
     
     - Parameters:
        - queryText: The text string the user is searching recipes for, e.g. Chicken
        - completion: A completion handler using a type alias that takes a boolean as an argument and returns nothing. It is used to signal to the user that the function has successfully completed and hence perform any further operations
     
     */
    func fetchRecipeWithQuery(queryText: String, completion: @escaping CompletionHandler) {
        recipeArray = []
        let url = "\(QUERY_URL)\(queryText)\(API_SECURITY_CREDENTIALS)\(FROM)\(TO)"
        
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
    
    /**
        A convinience function that takes in a JSON object using SwiftyJSON object notation and parses the objects properties, creating a new Recipe object using these parsed properties.
        The new object is that appended to an array of Recipes that is used as the DataSource of the TableView on ExploreVC.
        Note: SwiftyJSON has optionality built into its core, hence it will return the value if found or an empty property, e.g. empty string.
     
        - Parameters:
            - json: The JSON object to be parsed
     */
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
