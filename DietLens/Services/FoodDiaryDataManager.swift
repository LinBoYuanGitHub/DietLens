//
//  FoodDiaryDataManager.swift
//  DietLens
//
//  Created by linby on 08/11/2017.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation
class FoodDiaryDataManager{
    var foodDiaryDBOperation = FoodDiaryDBOperation.instance
    func saveFoodDiary(ratio:Float,foodInfo:FoodInfo,mealTime:String,mealType:String,recordType:String,imageId:String,picpath:String,foodCategory:String){
        let foodDiary:FoodDiary = FoodDiary()
        foodDiary.foodId = foodInfo.food_id
        foodDiary.foodName = foodInfo.food_name
        foodDiary.userId = "" //TODO get global user ID
        foodDiary.calorie = Double(foodInfo.calorie * ratio)
        foodDiary.carbohydrate = String(Float(foodInfo.carbohydrate)! * ratio)
        foodDiary.protein = String(Float(foodInfo.protein)! * ratio)
        foodDiary.fat = String(Float(foodInfo.fat)! * ratio)
        foodDiary.portionSize = Double(ratio * 100)
        foodDiary.mealTime = mealTime
        foodDiary.mealType = mealType
        foodDiary.recordType = recordType
        foodDiary.imageId = imageId
        foodDiaryDBOperation.SaveFoodDiary(foodDiary: foodDiary)
    }
    
    init(){
        
    }
    
}
