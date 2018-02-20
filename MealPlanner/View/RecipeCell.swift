//
//  RecipeCell.swift
//  MealPlanner
//
//  Created by Hayden Jamieson on 13/02/2018.
//  Copyright © 2018 Hayden Jamieson. All rights reserved.
//

import UIKit
import AlamofireImage
import SDWebImage


class RecipeCell: UITableViewCell {

    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var recipeName: UILabel!
    @IBOutlet weak var recipeSource: UILabel!
    @IBOutlet weak var recipeDiet: UILabel!
    @IBOutlet weak var recipeCalories: UILabel!
    @IBOutlet weak var recipeYield: UILabel!
    @IBOutlet weak var recipeFavouriteBtn: FancyButton!
    
    
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
        
        guard let url = URL(string: recipe.imageURL) else {return}
        self.recipeImage?.af_setImage(withURL: url, placeholderImage: nil,
                                    filter: nil,
                                    imageTransition: .flipFromTop(0.2))
        //recipeImage.sd_setImage(with: URL(string: recipe.imageURL), completed: nil)
    }

    

}
