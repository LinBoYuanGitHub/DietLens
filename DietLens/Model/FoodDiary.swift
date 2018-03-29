//
//  ArticleEntity.swift
//  DietLens
//
//  Created by linby on 04/11/2017.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation
import RealmSwift

class FoodDiary: Object {
    @objc dynamic var id = 0
    @objc dynamic var userId = "" //save current user?
    @objc dynamic var imageId = ""
    @objc dynamic var imagePath = ""//for local storage
    @objc dynamic var mealTime = ""
    @objc dynamic var mealType = ""
    @objc dynamic var recordType = ""
    @objc dynamic var quantity: Double = 0.0
    @objc dynamic var selectedFoodInfoPos: Int = 0
    @objc dynamic var selectedPortionPos: Int  = 0
    var foodInfoList = List<FoodInfomation>()
    let ingredientList = List<IngredientDiary>() // used only when user choose customized food

    override static func primaryKey() -> String? {
        return "id"
    }
}

class IngredientDiary: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var ingredientId: Int = 0
    @objc dynamic var ingredientName: String = ""
    @objc dynamic var calorie = 0.0
    @objc dynamic var carbs = 0.0
    @objc dynamic var protein = 0.0
    @objc dynamic var fat = 0.0
    @objc dynamic var sugarsTotal = 0.0
    @objc dynamic var quantity: Double = 0
    @objc dynamic var unit = ""
    @objc dynamic var weight = 0.0
}

class FoodInfomation: Object {
    @objc dynamic var foodId: String = ""
    @objc dynamic var rank: Int = 0
    @objc dynamic var foodName: String = ""
    @objc dynamic var carbohydrate: String = ""
    @objc dynamic var protein: String = ""
    @objc dynamic var fat: String = ""
    @objc dynamic var calorie: Float = 0.0
    @objc dynamic var category: String = ""
    @objc dynamic var sampleImagePath: String = ""
    let portionList = List<Portion>()
}

class Portion: Object {
    @objc dynamic var sizeUnit = ""
    @objc dynamic var sizeValue = 1
    @objc dynamic var weightValue = 0.0
    @objc dynamic var weightUnit = ""
    @objc dynamic var rank = 0
}
