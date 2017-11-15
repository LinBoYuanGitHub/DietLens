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

    func assembleFoodInfos(jsonArr: JSON) -> [FoodInfomation] {
         foodInfoList.removeAll()
         for i in 0..<jsonArr.count {
            var jsonObject = jsonArr[i]
            var foodInfo = FoodInfomation()
            foodInfo.foodId = jsonObject["food_id"].stringValue
            foodInfo.foodName = jsonObject["food_name"].stringValue
            if(foodInfo.foodName == "Non-food") {
                foodInfo.calorie = 0.0
                foodInfo.carbohydrate = "0.0"
                foodInfo.protein = "0.0"
                foodInfo.fat = "0.0"
            } else {
                foodInfo.calorie = Float(jsonObject["calorie"].stringValue)!
                foodInfo.carbohydrate = jsonObject["carbohydrate"].stringValue
                foodInfo.protein = jsonObject["protein"].stringValue
                foodInfo.fat = jsonObject["fat"].stringValue
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
        foodInfo.calorie = Float(jsonObject["calorie"].stringValue)!
        foodInfo.carbohydrate = jsonObject["carbohydrate"].stringValue
        foodInfo.protein = jsonObject["protein"].stringValue
        foodInfo.fat = jsonObject["fat"].stringValue
        return foodInfo
    }
}
