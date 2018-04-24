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
    public var foodInfoList = [FoodInfomationModel]()

    func assembleFoodInfos(jsonObj: JSON) -> [FoodInfomationModel] {
         foodInfoList.removeAll()
         var jsonArr = jsonObj["data"]["food_info"]
         for i in 0..<jsonArr.count {
            var jsonObject = jsonArr[i]
            var foodInfo = FoodInfomationModel()
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
            for json in jsonObject["portion"].arrayValue {
                var portion = PortionModel()
                portion.sizeValue = json["size_value"].intValue
                portion.rank = json["rank"].intValue
                portion.sizeUnit = json["size_unit"].stringValue
                portion.weightUnit = json["weight_unit"].stringValue
                portion.weightValue = json["weight_value"].doubleValue
                foodInfo.portionList.append(portion)
            }
            foodInfo.rank = i+1
            foodInfoList.append(foodInfo)
        }
        return foodInfoList
    }

    func assembleFoodInfo(jsonObject: JSON) -> FoodInfomationModel {
        var foodInfo = FoodInfomationModel()
        foodInfo.foodId = jsonObject["id"].stringValue
        foodInfo.foodName = jsonObject["display_name"].stringValue
        foodInfo.calorie = Float(jsonObject["nutrition"]["energy"].doubleValue)
        foodInfo.carbohydrate = String(jsonObject["nutrition"]["carbohydrate"].doubleValue)
        foodInfo.protein = String(jsonObject["nutrition"]["protein"].doubleValue)
        foodInfo.fat = String(jsonObject["nutrition"]["total_fat"].doubleValue)
        foodInfo.category = jsonObject["subcat"].stringValue
        for json in jsonObject["food_portion"].arrayValue {
            var portion = PortionModel()
            portion.rank = json["rank"].intValue
            portion.sizeValue = json["weight_g"].intValue
            portion.sizeUnit = json["measurement_type"].stringValue
            portion.weightUnit = json["measurement_type"].stringValue
            portion.weightValue = json["weight_g"].doubleValue
            foodInfo.portionList.append(portion)
        }
        return foodInfo
    }

    func assembleTextFoodInfo(jsonObject: JSON) -> FoodInfomationModel {
        var foodInfo = FoodInfomationModel()
        foodInfo.foodId = jsonObject["id"].stringValue
        foodInfo.foodName = jsonObject["display_name"].stringValue
        foodInfo.calorie = Float(jsonObject["energy"].stringValue)!
        foodInfo.carbohydrate = jsonObject["carbohydrate"].stringValue
        foodInfo.protein = jsonObject["protein"].stringValue
        foodInfo.fat = jsonObject["total_fat"].stringValue
        foodInfo.category = jsonObject["subcat"].stringValue
        for json in jsonObject["portion"].arrayValue {
            var portion = PortionModel()
            portion.sizeValue = json["size_value"].intValue
            portion.rank = json["rank"].intValue
            portion.sizeUnit = json["size_unit"].stringValue
            portion.weightUnit = json["weight_unit"].stringValue
            portion.weightValue = json["weight_value"].doubleValue
            foodInfo.portionList.append(portion)
        }
        return foodInfo
    }

    func assembleBarcodeFoodInfo(jsonObject: JSON) -> FoodInfomationModel {
        var foodInfo = FoodInfomationModel()
        foodInfo.foodId = jsonObject["id"].stringValue
        foodInfo.foodName = jsonObject["name"].stringValue
        foodInfo.calorie = Float(jsonObject["calories"].stringValue)!
        foodInfo.carbohydrate = jsonObject["carbohydrates"].stringValue
        foodInfo.protein = jsonObject["protein"].stringValue
        foodInfo.fat = jsonObject["total_fat"].stringValue
        foodInfo.category = "barcode"
        for json in jsonObject["portion"].arrayValue {
            var portion = PortionModel()
            portion.sizeValue = json["size_value"].intValue
            portion.rank = json["rank"].intValue
            portion.sizeUnit = json["size_unit"].stringValue
            portion.weightUnit = json["weight_unit"].stringValue
            portion.weightValue = json["weight_value"].doubleValue
            foodInfo.portionList.append(portion)
        }
        return foodInfo
    }

    func assembleIngredientInfo(jsonObject: JSON) -> Ingredient {
        var ingredient = Ingredient()
        ingredient.ingredientId = jsonObject["ID"].intValue
        ingredient.longDesc = jsonObject["Name"].stringValue
        if jsonObject["Carbohydrate"].stringValue == "null" {
            ingredient.carbs = "0.0"
        } else {
            ingredient.carbs = jsonObject["Carbohydrate"].stringValue
        }
        if jsonObject["Energy"].stringValue == "null" {
            ingredient.energyKcal = "0.0"
        } else {
            ingredient.energyKcal = jsonObject["Energy"].stringValue
        }
        if jsonObject["Protein"].stringValue == "null" {
            ingredient.protein = "0.0"
        } else {
            ingredient.protein = jsonObject["Protein"].stringValue
        }
        ingredient.fat = String(jsonObject["Total_fat"].doubleValue)
        if jsonObject["Sugar"].stringValue == "null" {
            ingredient.sugarsTotal = "0.0"
        } else {
            ingredient.sugarsTotal = jsonObject["Sugar"].stringValue
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

    func assembleFoodDiaryEntity(jsonObject: JSON) -> FoodDiaryEntity {
        var foodDiaryEntity = FoodDiaryEntity()
        foodDiaryEntity.foodDiaryId = jsonObject["id"].stringValue
        foodDiaryEntity.imageId = jsonObject["image"].stringValue
        foodDiaryEntity.mealTime = jsonObject["meal_time"].stringValue
        foodDiaryEntity.mealType = jsonObject["meal_type"].stringValue
        if(jsonObject["latitude"].stringValue != "" && jsonObject["longitude"].stringValue != "") {
            foodDiaryEntity.latitude = Double(jsonObject["latitude"].stringValue)!
            foodDiaryEntity.longitude = Double(jsonObject["longitude"].stringValue)!
        }
        for i in 0..<jsonObject["details"].count {
            var foodItem = DietItem()
            var job = jsonObject["details"][i]
            foodItem.foodId = job["id"].stringValue
            foodItem.foodName = job["name"].stringValue
            foodItem.quantity = Double(job["quantity"].intValue)
            foodItem.recordType = job["search_type"].stringValue
            foodDiaryEntity.dietItems.append(foodItem)
        }
        return foodDiaryEntity
    }

    func paramfyFoodDiaryEntity(foodDiaryEntity: FoodDiaryEntity) -> Dictionary<String, Any> {
        var result = Dictionary<String, Any>()
        result["meal_time"] = foodDiaryEntity.mealTime
        result["meal_type"] = foodDiaryEntity.mealType
        result["image"] = foodDiaryEntity.imageId
        //TODO remove hardcode
        result["user"] = "b7039d40-4394-11e8-9e66-64006a470149"
        var details = [Dictionary<String, Any>]()
        for dietItem in foodDiaryEntity.dietItems {
            var dietDict  = Dictionary<String, Any>()
            dietDict["name"] = dietItem.foodName
            dietDict["food"] = dietItem.foodId
            dietDict["search_type"] = dietItem.recordType
            dietDict["unit"] = dietItem.portionInfo[dietItem.selectedPos].sizeUnit
            dietDict["quantity"] = dietItem.quantity
            var nutrient = Dictionary<String, Double>()
            nutrient["fat"] = dietItem.nutritionInfo.fat
            nutrient["energy"] = dietItem.nutritionInfo.calorie
            nutrient["protein"] = dietItem.nutritionInfo.protein
            nutrient["carbohydrate"] = dietItem.nutritionInfo.carbohydrate
            dietDict["nutrient"] = nutrient
            //add nutrient part to
            details.append(dietDict)
        }
        result["details"] = details
        return result
    }

    func assembleFoodDiaryEntities(jsonObject: JSON) -> [FoodDiaryEntity] {
        var foodDiaryEntityList = [FoodDiaryEntity]()
        for result in jsonObject.arrayValue {
            let foodDiaryEntity = assembleFoodDiaryEntity(jsonObject: result)
            foodDiaryEntityList.append(foodDiaryEntity)
        }
        return foodDiaryEntityList
    }

}
