//
//  Constants.swift
//  MealPlanner
//
//  Created by Hayden Jamieson on 07/02/2018.
//  Copyright © 2018 Hayden Jamieson. All rights reserved.
//

import UIKit

let BASE_URL = "https://api.edamam.com/search?"
let APP_ID = "&app_id=e79c3ce6"
let APP_KEY = "&app_key=1672fdcf6bab01bfdcd5d18159b39fd9"
let QUERY_TEXT = "q="
let FROM = "&from=0"
let TO = "&to=30"
let DIET = "&diet="
let HEALTH = "&health="
let CALORIES = "&calories="
let CALORIES_LTE = "lte%20"
let CALORIES_GTE = ",%20gte%20"

let EXAMPLE_URL = "\(BASE_URL)\(QUERY_TEXT)chicken\(APP_ID)\(APP_KEY)\(FROM)\(TO)\(CALORIES)\(CALORIES_LTE)\(CALORIES_GTE)\(HEALTH)"

// Prefix & between variables

//https://api.edamam.com/search?q=chicken&app_id=${YOUR_APP_ID}&app_key=${YOUR_APP_KEY}&from=0&to=3&calories=gte%20591,%20lte%20722&health=alcohol-free

let KEY_UID = "uid"
let SHADOW_GRAY: CGFloat = 120.0 / 255.0
