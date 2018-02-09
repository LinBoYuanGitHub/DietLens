//
//  FoodInfoDataManager.swift
//  DietLens
//
//  Created by linby on 08/11/2017.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation
import SwiftyJSON

class FoodInfoDataManager {
    static var instance = FoodInfoDataManager()
    private init() {}
    public var foodInfoList = [FoodInfomation]()

    func assembleFoodInfos(jsonObj: JSON) -> [FoodInfomation] {
         foodInfoList.removeAll()
         var jsonArr = jsonObj["data"]["food_info"]
         for i in 0..<jsonArr.count {
            var jsonObject = jsonArr[i]
            var foodInfo = FoodInfomation()
//            foodInfo.foodId = jsonObject["food_id"].stringValue
            foodInfo.foodName = jsonObject["food_name"].stringValue
            if foodInfo.foodName == "Non-food" {
                foodInfo.calorie = 0.0
                foodInfo.carbohydrate = "0.0"
                foodInfo.protein = "0.0"
                foodInfo.fat = "0.0"
            } else {
                foodInfo.calorie = Float(jsonObject["calories"].stringValue)!
                foodInfo.carbohydrate = jsonObject["carbs"].stringValue
                foodInfo.protein = jsonObject["protein"].stringValue
                foodInfo.fat = jsonObject["fat"].stringValue
                foodInfo.sampleImagePath = jsonObject["food_sample_url"].stringValue
            }
            foodInfo.rank = i+1
            foodInfoList.append(foodInfo)
        }
        return foodInfoList
    }

    func assembleFoodInfo(jsonObject: JSON) -> FoodInfomation {
        var foodInfo = FoodInfomation()
        foodInfo.foodId = jsonObject["id"].stringValue
        foodInfo.foodName = jsonObject["name"].stringValue
        foodInfo.calorie = Float(jsonObject["energy"].stringValue)!
        foodInfo.carbohydrate = jsonObject["carbohydrate"].stringValue
        foodInfo.protein = jsonObject["protein"].stringValue
        foodInfo.fat = jsonObject["total_fat"].stringValue
        foodInfo.category = jsonObject["subcat"].stringValue
        return foodInfo
    }

    func assembleBarcodeFoodInfo(jsonObject: JSON) -> FoodInfomation {
        var foodInfo = FoodInfomation()
        foodInfo.foodId = jsonObject["id"].stringValue
        foodInfo.foodName = jsonObject["name"].stringValue
        foodInfo.calorie = Float(jsonObject["calories"].stringValue)!
        foodInfo.carbohydrate = jsonObject["carbohydrates"].stringValue
        foodInfo.protein = jsonObject["protein"].stringValue
        foodInfo.fat = jsonObject["total_fat"].stringValue
        foodInfo.category = "barcode"
        return foodInfo
    }

    func assembleIngredientInfo(jsonObject: JSON) -> Ingredient {
        var ingredient = Ingredient()
        ingredient.ingredientId = jsonObject["ID"].intValue
        ingredient.long_desc = jsonObject["Name"].stringValue
        if jsonObject["Carbohydrate"].stringValue == "null" {
            ingredient.carbs = "0.0"
        } else {
            ingredient.carbs = jsonObject["Carbohydrate"].stringValue
        }
        if jsonObject["Energy"].stringValue == "null" {
            ingredient.energy_kcal = "0.0"
        } else {
            ingredient.energy_kcal = jsonObject["Energy"].stringValue
        }
        if jsonObject["Protein"].stringValue == "null" {
            ingredient.protein = "0.0"
        } else {
            ingredient.protein = jsonObject["Protein"].stringValue
        }
        ingredient.fat = String(jsonObject["Total_fat"].doubleValue)
        if jsonObject["Sugar"].stringValue == "null" {
            ingredient.sugars_total = "0.0"
        } else {
            ingredient.sugars_total = jsonObject["Sugar"].stringValue
        }
        for i in 0..<jsonObject["unit_list"].count {
            var unit = IngredientUnit()
            var job = jsonObject["unit_list"][i]
            unit.unitId = job["id"].intValue
            unit.seq = job["seq"].stringValue
            unit.amount = job["amount"].stringValue
            unit.unit = job["unit"].stringValue
            unit.weight = job["weight_g"].stringValue
            ingredient.ingredientUnit.append(unit)
        }
        return ingredient
    }
}
