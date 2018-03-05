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
    
    var cacheWrapper: ImageCachingWrapper?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cacheWrapper = ImageCachingWrapper()
        recipeImage.clipsToBounds = true
        recipeImage.layer.cornerRadius = 10
        recipeImage.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    
    /**
        A function to set up the table view cells outlets using the properties of the Recipe object provided.
        We use functional programming & a higher order function to convert the dietLabels array (of JSON object type) into a String array using the map function. This is so we can join the array's contents into a single string and show it in the cell.
        We then retrieve the image for the specific recipe.
     
        - Parameters:
            - recipe: The Recipe object used to populate the cell contents
     */
    func configureCell(withRecipe recipe: Recipe) {
        reset()

        let stringArr:[String] = recipe.dietLabels.map {"\($0)"}
        let dietLabelString = stringArr.joined(separator: ", ")
        
        self.recipeName.text = recipe.name
        self.recipeSource.text = recipe.source
        self.recipeDiet.text = dietLabelString
        
        if let calories = recipe.calories {
            self.recipeCalories.text = "Calories: \(Int(calories.rounded()))"
        }
        
        if let yield = recipe.yield {
            self.recipeYield.text = "Feeds: \(yield)"
        }
        
        loadImage(recipe: recipe)
    }
    
    // MARK: Image retrieval and image caching
    
    /**
        A function to load the recipe image using the imageURL for the specified Recipe object.
        We first safely unwrap the url, then we check to see if we have a cached image and if we do we use it.
        Otherwise we retrieve the image using AlamofireImage, which will download the image and animate it in. We then add the image to the imageCache using the url as its identifier so that it can be grabbed from the cache in future.
     
        - Parameters:
            - recipe: The Recipe object to grab the image for.
     */
    func loadImage(recipe: Recipe) {
        guard let imageUrl = URL(string: recipe.imageURL) else {return}
    
        if let image = cacheWrapper?.cachedImage(for: recipe.imageURL) {
            print("HJ: Using cached image")
            recipeImage.image = image
            return
        }
    
        self.recipeImage?.af_setImage(withURL: imageUrl, placeholderImage: nil, filter: nil, imageTransition: .flipFromTop(0.2))
        if let imageToCache = recipeImage.image {
            self.cacheWrapper?.cache(imageToCache, for: recipe.imageURL)
        }
    }
    
    /*
        Since Table Views reuse, we need to make sure we are loading the right image for each cell as we scroll. If the request is still in-flight when cell is reused, cell could be populated with wrong image.
        General fix is to reset the cell - nil the image and cancel any request, then do the Cell configuration. I.e. Call reset at the start of configureCell()
     */
    func reset() {
        recipeImage.image = nil
    }
}


