//
//  FoodDiaryEntity.swift
//  DietLens
//
//  Created by linby on 17/04/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import Foundation

class FoodDiaryEntity {
    public var foodDiaryId: String = ""
    public var imageId: String = ""
    public var placeHolderImage: String = ""
    public var mealTime: String = ""
    public var mealType: String = ""
    public var latitude = 0.0
    public var longitude = 0.0
    public var dietItems = [DietItem]()

    func copy() -> FoodDiaryEntity {
        let copy = FoodDiaryEntity()
        copy.foodDiaryId = foodDiaryId
        copy.imageId = imageId
        copy.placeHolderImage = placeHolderImage
        copy.mealTime = mealTime
        copy.mealType = mealType
        copy.latitude = latitude
        copy.longitude = longitude
        copy.dietItems = dietItems
        return copy
    }
}

class DietItem {
    public var id: String = ""
    public var foodId: Int = 0
    public var foodName: String = ""
    public var selectedPos: Int = 0
    public var quantity: Double = 1.0
    public var displayUnit: String = ""
    public var recordType = ""
    public var category = ""
    public var sampleImageUrl = ""
    public var isMixFood = false
    public var portionInfo  = [PortionInfo]()
    public var nutritionInfo = NutritionInfo()
    public var isFavoriteFood = false
}

class NutritionInfo {
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

class PortionInfo {
    public var sizeUnit = ""
    public var sizeValue = 1
    public var weightValue = 0.0
    public var weightUnit = ""
    public var rank = 0
}
