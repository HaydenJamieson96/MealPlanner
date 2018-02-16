//
//  Recipe.swift
//  MealPlanner
//
//  Created by Hayden Jamieson on 16/02/2018.
//  Copyright © 2018 Hayden Jamieson. All rights reserved.
//

import Foundation

struct Recipe {
    
    public private(set) var name: String!
    public private(set) var source: String!
    public private(set) var imageURL: String!
    public private(set) var url: String!
    public private(set) var yield: Int!
    public private(set) var dietLabels: [Any]
    public private(set) var healthLabels: [Any]
    public private(set) var ingredientLines: [Any]
    public private(set) var calories: Double!
    public private(set) var totalDailyNutrients: [String: Any]
}
