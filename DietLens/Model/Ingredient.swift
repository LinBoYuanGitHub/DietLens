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
    var longDesc: String = ""
    var energyKcal = ""
    var carbs = ""
    var protein: String = ""
    var fat = ""
    var sugarsTotal = ""
    var ingredientUnit = [IngredientUnit]()
}

struct IngredientUnit {
    var unitId = 0
    var seq = ""
    var amount = ""
    var unit = ""
    var weight = ""
}
