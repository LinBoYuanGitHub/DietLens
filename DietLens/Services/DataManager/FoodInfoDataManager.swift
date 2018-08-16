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
         for index in 0..<jsonArr.count {
            var jsonObject = jsonArr[index]
            var foodInfo = FoodInfomationModel()
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
            foodInfo.rank = index+1
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

    func assembleDietItem(jsonObject: JSON) -> DietItem {
        var dietItem = DietItem()
        dietItem.foodId = jsonObject["id"].intValue
        dietItem.isMixFood = jsonObject["is_mix_food"].boolValue
        dietItem.foodName = jsonObject["display_name"].stringValue
        dietItem.sampleImageUrl = jsonObject["example_img"].stringValue
        dietItem.nutritionInfo.calorie = jsonObject["nutrition"]["energy"].doubleValue
        dietItem.nutritionInfo.carbohydrate = jsonObject["nutrition"]["carbohydrate"].doubleValue
        dietItem.nutritionInfo.protein = jsonObject["nutrition"]["protein"].doubleValue
        dietItem.nutritionInfo.fat = jsonObject["nutrition"]["fat"].doubleValue
        dietItem.category = jsonObject["subcat"].stringValue
        for json in jsonObject["food_portion"].arrayValue {
            var portion = PortionInfo()
            portion.rank = json["rank"].intValue
            portion.sizeUnit = json["measurement_type"].stringValue
            portion.weightValue = json["weight_g"].doubleValue
            dietItem.portionInfo.append(portion)
        }
        //sort for portion according to the rank
        dietItem.portionInfo.sort { (portionA, portionB) -> Bool in
            portionA.rank < portionB.rank
        }
        return dietItem
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
        for index in 0..<jsonObject["unit_list"].count {
            var unit = IngredientUnit()
            var job = jsonObject["unit_list"][index]
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
        for index in 0..<jsonObject["details"].count {
            var foodItem = DietItem()
            var job = jsonObject["details"][index]
            foodItem.foodId = job["id"].intValue
            foodItem.foodName = job["name"].stringValue
            foodItem.quantity = Double(job["quantity"].doubleValue)
            foodItem.displayUnit = job["measurement_type"].stringValue
            foodItem.recordType = job["search_type"].stringValue
            foodDiaryEntity.dietItems.append(foodItem)
        }
        return foodDiaryEntity
    }

    func partialParamfyFoodDiaryEntity(foodDiaryEntity: FoodDiaryEntity) -> Dictionary<String, Any> {
        var result = [String: Any]()
        result["meal_time"] = foodDiaryEntity.mealTime
        result["meal_type"] = foodDiaryEntity.mealType
        result["image"] = foodDiaryEntity.imageId
        let preferences = UserDefaults.standard
        let userId = preferences.string(forKey: PreferenceKey.userIdkey)
        result["user"] = userId
        return result
    }

    func paramfyFoodDiaryEntity(foodDiaryEntity: FoodDiaryEntity) -> Dictionary<String, Any> {
        var result = [String: Any]()
        result["meal_time"] = foodDiaryEntity.mealTime
        result["meal_type"] = foodDiaryEntity.mealType
        result["image"] = foodDiaryEntity.imageId
        let preferences = UserDefaults.standard
        let userId = preferences.string(forKey: PreferenceKey.userIdkey)
        result["user"] = userId
        var details = [Dictionary<String, Any>]()
        for dietItem in foodDiaryEntity.dietItems {
            var dietDict  = Dictionary<String, Any>()
            if dietItem.id != "" {
                 dietDict["id"] = dietItem.id
            }
            dietDict["name"] = dietItem.foodName
            dietDict["food"] = dietItem.foodId
            dietDict["search_type"] = dietItem.recordType
            if dietItem.portionInfo.count != 0 {
                dietDict["measurement_type"] = dietItem.portionInfo[dietItem.selectedPos].sizeUnit
            } else if dietItem.displayUnit != "" {
                dietDict["measurement_type"] = dietItem.displayUnit
            } else {
                dietDict["measurement_type"] = "portion"
            }
            dietDict["quantity"] = dietItem.quantity
            var portionArr = [Dictionary<String, Any>]()
            var portionDict = Dictionary<String, Any>()
            for portion in dietItem.portionInfo {
                portionDict["type"] = portion.sizeUnit
                portionDict["weight"] = portion.weightValue
                portionArr.append(portionDict)
            }
            dietDict["portion"] = portionArr
            dietDict["selected_position"] = dietItem.selectedPos
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

    public func assembleDisplayFoodCategoryData(data: JSON) -> [DisplayFoodCategory] {
        var resultList = [DisplayFoodCategory]()
        var bestMatchCategory = DisplayFoodCategory()
        let bestMatchs = data["best_match"].arrayValue
        let subcats = data["subcat"].arrayValue
        for bestMatch in bestMatchs {
            var match = DisplayFoodInfo()
            match.id = bestMatch["id"].intValue
            match.displayName = bestMatch["display_name"].stringValue
            match.exampleImgUrl = bestMatch["example_img"].stringValue
            match.calories = bestMatch["nutrition"]["energy"].doubleValue
            bestMatchCategory.subcateFoodList.append(match)
        }
        bestMatchCategory.subcatName = "Best Match" //insert a sample Image that controll by the backend will be better
        bestMatchCategory.subcatImageUrl = ""
        resultList.append(bestMatchCategory)
        for subcat in subcats {
            var subCategory = DisplayFoodCategory()
            let foodInfos = subcat["food_info"].arrayValue
            subCategory.subcatImageUrl = subcat["subcat_image"].stringValue
            subCategory.subcatName = subcat["subcat"].stringValue
            for foodInfo in foodInfos {
                var foodObject = DisplayFoodInfo()
                foodObject.id = foodInfo["id"].intValue
                foodObject.displayName = foodInfo["display_name"].stringValue
                foodObject.exampleImgUrl = foodInfo["example_img"].stringValue
                foodObject.calories = foodInfo["nutrition"]["energy"].doubleValue
                foodObject.isMultiDish = foodInfo["is_mix_food"].boolValue
                foodObject.unit = foodInfo["unit"].stringValue
                subCategory.subcateFoodList.append(foodObject)
            }
            resultList.append(subCategory)
        }
        return resultList
    }

}