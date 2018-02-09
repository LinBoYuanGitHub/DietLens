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
    @objc dynamic var foodName = ""
    @objc dynamic var rank = 1
    @objc dynamic var userId = ""
    @objc dynamic var foodId = ""
    @objc dynamic var imageId = ""
    @objc dynamic var imagePath = ""
    @objc dynamic var mealTime = ""
    @objc dynamic var mealType = ""
    @objc dynamic var recordType = ""
    @objc dynamic var portionSize: Double = 100.0
    @objc dynamic var calorie = 0.0
    @objc dynamic var carbohydrate = "0.0"
    @objc dynamic var protein = "0.0"
    @objc dynamic var fat = "0.0"
    @objc dynamic var category = ""
    let ingredientList = List<IngredientDiary>() // used only when user choose customized food
}

class IngredientDiary: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var ingredientId: Int = 0
    @objc dynamic var ingredientName: String = ""
    @objc dynamic var calorie = 0.0
    @objc dynamic var carbs = 0.0
    @objc dynamic var protein = 0.0
    @objc dynamic var fat = 0.0
    @objc dynamic var sugars_total = 0.0
    @objc dynamic var quantity: Double = 0
    @objc dynamic var unit = ""
    @objc dynamic var weight = 0.0
}
