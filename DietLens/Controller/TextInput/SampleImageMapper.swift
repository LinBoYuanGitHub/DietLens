//
//  SampleImageMapper.swift
//  DietLens
//
//  Created by linby on 04/12/2017.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation
import UIKit
class SampleImageMapper {
    static var instance = SampleImageMapper()
    private init() {}

    func getFoodSampleImage(foodCategory: String) -> UIImage {
        switch (foodCategory) {
        case "NonAlcoholicDrinks":
            return #imageLiteral(resourceName: "sampleCategoryNonAlcoholicDrinks")
        case "AlcoholicDrinks":
            return #imageLiteral(resourceName: "sampleCategoryAlcoholic")
        case "Cereals":
            return #imageLiteral(resourceName: "sampleCategoryCereals")
        case "FastFood":
            return #imageLiteral(resourceName: "sampleCategoryFastFood")
        case "Seafood":
            return #imageLiteral(resourceName: "sampleCategorySeafoods")
        case "Vegetables":
            return #imageLiteral(resourceName: "sampleCategoryVegetables")
        case "Fruits":
            return #imageLiteral(resourceName: "sampleCategoryFruits")
        case "Eggs":
            return #imageLiteral(resourceName: "sampleCategoryEggs")
        case "Breads":
            return #imageLiteral(resourceName: "sampleCategoryBreads")
        case "Desserts":
            return #imageLiteral(resourceName: "sampleCategoryDessert")
        case "Meats":
            return #imageLiteral(resourceName: "sampleCategoryMeats")
        case "DairyItems":
            return #imageLiteral(resourceName: "sampleCategoryDairyItems")
        case "BarcodeItems":
            return #imageLiteral(resourceName: "barcode_sample_icon")
        case "Nuts":
            return #imageLiteral(resourceName: "sampleCategoryNuts")
        case "ConvenienceMeals":
            return #imageLiteral(resourceName: "sampleCategoryConvenienceMeals")
        case "CannedSoup":
            return #imageLiteral(resourceName: "sampleCategoryCannedSoup")
        case "MiscItems":
            return #imageLiteral(resourceName: "sampleCategoryMiscItems")
        default:
            return #imageLiteral(resourceName: "food_sample_image")
        }
    }
}
