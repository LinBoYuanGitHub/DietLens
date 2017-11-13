//
//  FoodInfoDataManager.swift
//  DietLens
//
//  Created by linby on 08/11/2017.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation
import SwiftyJSON

class FoodInfoDataManager{
    static var instance = FoodInfoDataManager()
    private init(){}
    public var foodInfoList = [FoodInfo]()
    
    func assembleFoodInfos(jsonArr:[JSON]){
        for item in jsonArr{
            var foodInfo = assembleFoodInfo(jsonObject: item)
            if(foodInfo.food_name == "Non-food"){
                foodInfo.calorie = 0.0
                foodInfo.carbohydrate = "0.0"
                foodInfo.protein = "0.0"
                foodInfo.fat = "0.0"
            }
            foodInfoList.append(foodInfo)
        }
    }
    
    func assembleFoodInfo(jsonObject:JSON) -> FoodInfo{
        var foodInfo = FoodInfo()
        foodInfo.food_id = jsonObject["food_id"].stringValue
        foodInfo.food_name = jsonObject["food_name"].stringValue
        foodInfo.calorie = Float(jsonObject["calorie"].stringValue)!
        foodInfo.carbohydrate = jsonObject["carbohydrate"].stringValue
        foodInfo.protein = jsonObject["protein"].stringValue
        foodInfo.fat = jsonObject["fat"].stringValue
        return foodInfo
    }
}
