//
//  FoodDiaryEntity.swift
//  DietLens
//
//  Created by linby on 17/04/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import Foundation

struct FoodDiaryEntity {
    public var foodDiaryId: String = ""
    public var imageId: String = ""
    public var mealTime: String = ""
    public var mealType: String = ""
    public var latitude = 0.0
    public var longitude = 0.0
    public var dietItems = [DietItem]()
}

struct DietItem {
    public var id: String = ""
    public var foodId: Int = 0
    public var foodName: String = ""
    public var selectedPos: Int = 0
    public var quantity: Double = 1.0
    public var displayUnit: String = ""
    public var recordType = ""
    public var category = ""
    public var portionInfo  = [PortionInfo]()
    public var nutritionInfo = NutritionInfo()
}

struct NutritionInfo {
    public var calorie = 0.0
    public var carbohydrate = 0.0
    public var protein = 0.0
    public var fat = 0.0
    public var sugar = 0.0
    public var calcium = 0.0
    public var sodium = 0.0
    public var cholest = 0.0
    public var fiber = 0.0
    public var saturatedFat = 0.0
    public var transfat = 0.0

}

struct PortionInfo {
    public var sizeUnit = ""
    public var sizeValue = 1
    public var weightValue = 0.0
    public var weightUnit = ""
    public var rank = 0
}
