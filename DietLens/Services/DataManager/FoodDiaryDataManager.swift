//
//  FoodDiaryDataManager.swift
//  DietLens
//
//  Created by linby on 08/11/2017.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation
import SwiftyJSON

class FoodDiaryDataManager {

    static var instance = FoodDiaryDataManager()

    public var mealEntity = [DiaryDailyFood]()

    public var foodDiaryEntity = FoodDiaryEntity() //for FoodDiary entry
    public var foodDiaryList = [FoodDiaryEntity]() //for all the foodDiary history

    init() {

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
            foodItem.id = job["id"].stringValue
            foodItem.foodId = job["food"].intValue
            foodItem.foodName = job["name"].stringValue
            //prevent quantity equals zero
            if job["quantity"].intValue == 0 {
                foodItem.quantity = 1
            } else {
                foodItem.quantity = Double(job["quantity"].intValue)
            }
            foodItem.displayUnit = job["measurement_type"].stringValue
            foodItem.recordType = job["search_type"].stringValue
            foodItem.nutritionInfo.calorie = job["nutrient"]["energy"].doubleValue/foodItem.quantity
            foodItem.nutritionInfo.carbohydrate = job["nutrient"]["carbohydrate"].doubleValue/foodItem.quantity
            foodItem.nutritionInfo.protein = job["nutrient"]["protein"].doubleValue/foodItem.quantity
            foodItem.nutritionInfo.fat = job["nutrient"]["fat"].doubleValue/foodItem.quantity
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
            dietDict["measurement_type"] = dietItem.portionInfo[dietItem.selectedPos].sizeUnit
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
