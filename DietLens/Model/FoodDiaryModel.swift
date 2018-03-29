//
//  FoodDiaryModel.swift
//  DietLens
//
//  Created by linby on 15/03/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import Foundation

struct FoodDiaryModel {
    var id = 0
    var userId = "" //save current user?
    var imageId = ""
    var imagePath = ""//for local storage
    var mealTime = ""
    var mealType = ""
    var recordType = ""
    var quantity: Double = 1.0
    var selectedFoodInfoPos: Int = 0
    var selectedPortionPos: Int  = 0
    var foodInfoList = [FoodInfomationModel]()
    var ingredientList = [IngredientDiaryModel]() // used only when user choose customized food

    public func convertToStorage() -> FoodDiary {
        let foodDiary = FoodDiary()
        foodDiary.id = id
        foodDiary.userId = userId
        foodDiary.imageId = imageId
        foodDiary.imagePath = imagePath
        foodDiary.mealTime = mealTime
        foodDiary.mealType = mealType
        foodDiary.recordType = recordType
        foodDiary.quantity = quantity
        foodDiary.selectedFoodInfoPos = selectedFoodInfoPos
        foodDiary.selectedPortionPos = selectedPortionPos
        for foodInfo in foodInfoList {
            let foodInfoEntity = foodInfo.convertToStorage()
            foodDiary.foodInfoList.append(foodInfoEntity)
        }
        for ingredient in ingredientList {
            let ingredientEntity = ingredient.convertToStorage()
            foodDiary.ingredientList.append(ingredientEntity)
        }
        return foodDiary
    }

    public mutating func convertToObject(foodDiary: FoodDiary) {
        self.id = foodDiary.id
        self.userId = foodDiary.userId
        self.imageId = foodDiary.imageId
        self.imagePath = foodDiary.imagePath
        self.mealTime  = foodDiary.mealTime
        self.mealType = foodDiary.mealType
        self.recordType = foodDiary.recordType
        self.quantity = foodDiary.quantity
        self.selectedFoodInfoPos = foodDiary.selectedFoodInfoPos
        self.selectedPortionPos = foodDiary.selectedPortionPos
        for foodInfo in foodDiary.foodInfoList {
            var foodInfoModel = FoodInfomationModel()
            foodInfoModel.convertToObject(foodInfo: foodInfo)
            self.foodInfoList.append(foodInfoModel)
        }
        for ingredient in foodDiary.ingredientList {
            var ingredientModel = IngredientDiaryModel()
            ingredientModel.convertToObject(ingredientDiary: ingredient)
            self.ingredientList.append(ingredientModel)
        }
    }
}

struct IngredientDiaryModel {
    var id: Int = 0
    var ingredientId: Int = 0
    var ingredientName: String = ""
    var calorie = 0.0
    var carbs = 0.0
    var protein = 0.0
    var fat = 0.0
    var sugarsTotal = 0.0
    var quantity: Double = 0
    var unit = ""
    var weight = 0.0

    public func convertToStorage() -> IngredientDiary {
        let ingredient = IngredientDiary()
        ingredient.id = self.id
        ingredient.ingredientId = self.ingredientId
        ingredient.ingredientName = self.ingredientName
        ingredient.calorie = self.calorie
        ingredient.carbs = self.carbs
        ingredient.protein = self.protein
        ingredient.fat = self.fat
        ingredient.sugarsTotal = self.sugarsTotal
        ingredient.quantity = self.quantity
        ingredient.unit = self.unit
        ingredient.weight = self.weight
        return ingredient
    }

    public mutating func convertToObject(ingredientDiary: IngredientDiary) {
        self.id = ingredientDiary.id
        self.ingredientId = ingredientDiary.ingredientId
        self.ingredientName = ingredientDiary.ingredientName
        self.calorie = ingredientDiary.calorie
        self.carbs = ingredientDiary.carbs
        self.protein = ingredientDiary.protein
        self.fat = ingredientDiary.fat
        self.sugarsTotal = ingredientDiary.sugarsTotal
        self.quantity = ingredientDiary.quantity
        self.unit = ingredientDiary.unit
        self.weight = ingredientDiary.weight
    }
}

struct FoodInfomationModel {
    var foodId: String = ""
    var rank: Int = 0
    var foodName: String = ""
    var carbohydrate: String = ""
    var protein: String = ""
    var fat: String = ""
    var calorie: Float = 0.0
    var category: String = ""
    var sampleImagePath: String = ""
    var portionList: [PortionModel] = []

    public func convertToStorage() -> FoodInfomation {
        let foodInfo = FoodInfomation()
        foodInfo.foodId = self.foodId
        foodInfo.rank = self.rank
        foodInfo.foodName = self.foodName
        foodInfo.calorie = self.calorie
        foodInfo.carbohydrate = self.carbohydrate
        foodInfo.protein = self.protein
        foodInfo.fat = self.fat
        foodInfo.category = self.category
        foodInfo.sampleImagePath = self.sampleImagePath
        for portion in portionList {
            let portionEntity = portion.convertToStorage()
            foodInfo.portionList.append(portionEntity)
        }
        return foodInfo
    }

    public mutating func convertToObject(foodInfo: FoodInfomation) {
        self.foodId = foodInfo.foodId
        self.rank = foodInfo.rank
        self.foodName = foodInfo.foodName
        self.calorie = foodInfo.calorie
        self.carbohydrate = foodInfo.carbohydrate
        self.protein = foodInfo.protein
        self.fat = foodInfo.fat
        self.category = foodInfo.category
        self.sampleImagePath = foodInfo.sampleImagePath
        for portion in foodInfo.portionList {
            var portionObject = PortionModel()
            portionObject.convertToModel(portion: portion)
            self.portionList.append(portionObject)
        }
    }
}

struct PortionModel {
    var sizeUnit = ""
    var sizeValue = 1
    var weightValue = 0.0
    var weightUnit = ""
    var rank = 0

    public func convertToStorage() -> Portion {
        let portion = Portion()
        portion.rank = self.rank
        portion.sizeUnit = self.sizeUnit
        portion.sizeValue = self.sizeValue
        portion.weightUnit = self.weightUnit
        portion.weightValue = self.weightValue
        return portion
    }

    public mutating func convertToModel(portion: Portion) {
        self.rank = portion.rank
        self.sizeUnit = portion.sizeUnit
        self.sizeValue = portion.sizeValue
        self.weightUnit = portion.weightUnit
        self.weightValue = portion.weightValue
    }
}
