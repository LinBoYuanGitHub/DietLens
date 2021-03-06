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

    public var foodDiaryEntity = FoodDiaryEntity() //for FoodDiary entry
    public var foodDiaryList = [FoodDiaryEntity]() //for all the foodDiary history

    init() {

    }

    func assembleFoodDiaryEntity(jsonObject: JSON) -> FoodDiaryEntity {
        let foodDiaryEntity = FoodDiaryEntity()
        foodDiaryEntity.foodDiaryId = jsonObject["id"].stringValue
        foodDiaryEntity.imageId = jsonObject["image"].stringValue
        foodDiaryEntity.placeHolderImage = jsonObject["placeholder_img"].stringValue
        foodDiaryEntity.mealTime = jsonObject["meal_time"].stringValue
        foodDiaryEntity.mealType = jsonObject["meal_type"].stringValue
        if(jsonObject["latitude"].stringValue != "" && jsonObject["longitude"].stringValue != "") {
            foodDiaryEntity.latitude = Double(jsonObject["latitude"].stringValue)!
            foodDiaryEntity.longitude = Double(jsonObject["longitude"].stringValue)!
        }
        for index in 0..<jsonObject["details"].count {
            var foodItem = DietItem()
            var job = jsonObject["details"][index]
            foodItem.id = job["id"].stringValue
            foodItem.foodId = job["food"].intValue
            foodItem.foodName = job["name"].stringValue
            foodItem.sampleImageUrl = job["example_img"].stringValue
            if job["iodine_level"].exists() {
                foodItem.iodineLevel = job["iodine_level"].intValue
            }
            foodItem.isFavoriteFood = job["is_favorite_food"].boolValue
            //prevent quantity equals zero
            if job["quantity"].doubleValue == 0 {
                foodItem.quantity = 1
            } else {
                foodItem.quantity = job["quantity"].doubleValue
            }
            foodItem.displayUnit = job["measurement_type"].stringValue
            foodItem.selectedPos = job["selected_position"].intValue
            foodItem.recordType = job["search_type"].stringValue
            foodItem.nutritionInfo.calorie = job["nutrient"]["energy"].doubleValue
            foodItem.nutritionInfo.carbohydrate = job["nutrient"]["carbohydrate"].doubleValue
            foodItem.nutritionInfo.protein = job["nutrient"]["protein"].doubleValue
            foodItem.nutritionInfo.fat = job["nutrient"]["fat"].doubleValue
            //portion
            for indexNum in 0..<job["portion"].count {
                var portionJson = job["portion"][indexNum]
                var portionObj = PortionInfo()
                portionObj.sizeUnit = portionJson["type"].stringValue
                portionObj.weightValue = portionJson["weight"].doubleValue
                foodItem.portionInfo.append(portionObj)
            }
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
