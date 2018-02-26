//
//  RecipeCell.swift
//  MealPlanner
//
//  Created by Hayden Jamieson on 13/02/2018.
//  Copyright © 2018 Hayden Jamieson. All rights reserved.
//

import UIKit
import AlamofireImage

class RecipeCell: UITableViewCell {

    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var recipeName: UILabel!
    @IBOutlet weak var recipeSource: UILabel!
    @IBOutlet weak var recipeDiet: UILabel!
    @IBOutlet weak var recipeCalories: UILabel!
    @IBOutlet weak var recipeYield: UILabel!
    @IBOutlet weak var recipeFavouriteBtn: FancyButton!
    
    // Set maximum cache size and preferrred size to cut down to when max is reached
    let imageCache = AutoPurgingImageCache(memoryCapacity: UInt64(100).megabytes(), preferredMemoryUsageAfterPurge: UInt64(60).megabytes())
    
    override func awakeFromNib() {
        super.awakeFromNib()
        recipeImage.clipsToBounds = true
        recipeImage.layer.cornerRadius = 10
        recipeImage.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    
    func configureCell(withRecipe recipe: Recipe) {
        /*
            Using functional programming to convert the JSON array into a String array using map function, to allow us to join the array into a single string
            to show.
         */
        let stringArr:[String] = recipe.dietLabels.map {"\($0)"}
        let dietLabelString = stringArr.joined(separator: ", ")
        
        self.recipeName.text = recipe.name
        self.recipeSource.text = recipe.source
        self.recipeDiet.text = dietLabelString
        
        if let calories = recipe.calories {
            self.recipeCalories.text = "Calores: \(Double(round(1000*calories)/1000))"
        }
        
        if let yield = recipe.yield {
            self.recipeYield.text = "Feeds: \(yield)"
        }
        
        loadImage(recipe: recipe)
    }
    
    // MARK: Image retrieval and image caching
    
    func loadImage(recipe: Recipe) {
        guard let imageUrl = URL(string: recipe.imageURL) else {return}
        
        // Check if we have cached image before retrieving, if so, use it instead
        if let image = cachedImage(for: recipe.imageURL) {
            print("HJ: Using cached image")
            recipeImage.image = image
            return
        }
        
        // Retrieve the image, create a cache for it using the URL as the identifier
        self.recipeImage?.af_setImage(withURL: imageUrl, placeholderImage: nil,
                                      filter: nil,
                                      imageTransition: .flipFromTop(0.2))
        if let imageToCache = recipeImage.image {
            self.cache(imageToCache, for: recipe.imageURL)
        }
    }
    
    func cache(_ image: Image, for url: String) {
        imageCache.add(image, withIdentifier: url)
    }
    
    func cachedImage(for url: String) -> Image? {
        return imageCache.image(withIdentifier: url)
    }
    
}

extension UInt64 {
    func megabytes() -> UInt64 {
        return self * 1024 * 1024
    }
}
