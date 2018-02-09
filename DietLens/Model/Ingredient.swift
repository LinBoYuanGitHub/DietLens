//
//  Ingredient.swift
//  DietLens
//
//  Created by linby on 19/01/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import Foundation

struct Ingredient {
    var ingredientId: Int = 0
    var long_desc: String = ""
    var energy_kcal = ""
    var carbs = ""
    var protein: String = ""
    var fat = ""
    var sugars_total = ""
    var ingredientUnit = [IngredientUnit]()
}

struct IngredientUnit {
    var unitId = 0
    var seq = ""
    var amount = ""
    var unit = ""
    var weight = ""
}
