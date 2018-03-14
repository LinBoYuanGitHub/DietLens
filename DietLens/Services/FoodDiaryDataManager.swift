//
//  FoodDiaryDataManager.swift
//  DietLens
//
//  Created by linby on 08/11/2017.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation
class FoodDiaryDataManager {

    static var instance = FoodDiaryDataManager()

    public var mealEntity = [DiaryDailyFood]()
    public var foodDiaryList = [FoodDiary]()

    private var foodDiaryDBOperation = FoodDiaryDBOperation.instance
    func saveFoodDiary(ratio: Float, foodInfo: FoodInfomation, mealTime: String, mealType: String, recordType: String, imageId: String, picpath: String, foodCategory: String) {
        let foodDiary: FoodDiary = FoodDiary()
        foodDiary.foodId = foodInfo.foodId
        foodDiary.foodName = foodInfo.foodName
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
        foodDiaryDBOperation.saveFoodDiary(foodDiary: foodDiary)
    }

    init() {

    }

}
