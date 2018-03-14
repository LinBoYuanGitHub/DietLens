//
//  DairyDailyModel.swift
//  DietLens
//
//  Created by next on 7/11/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage
import RealmSwift

public enum Meal: Int {
    case breakfast
    case lunch
    case dinner
    case snack
}

struct DiaryDailyFood {
    var mealOfDay: Meal = .breakfast
    var foodConsumed = [FoodDiary]()
}

//struct FoodInfo {
//    var id: Int = 0
//    var foodName: String = ""
//    var calories: Double = 0
//    var carbohydrate: String = ""
//    var protein: String = ""
//    var fat: String = ""
//    var mealType: String = ""
//    var imageURL: String?
//    var servingSize: String = ""
//    var portionSize: Double = 100
//    var quantity: Double = 1.0
//    var unit: String = ""
//    var recordType: String = ""
//    var ingredientList = List<IngredientDiary>()
//
//    init() {
//        self.foodName = ""
//        self.calories = 0
//        self.mealType = ""
//        self.imageURL = ""
//        self.servingSize = ""
//    }
//
//    init(food: FoodDiary) {
//        self.foodName = food.foodName
//        self.calories = food.calorie
//        self.servingSize = String(food.portionSize)
//        self.mealType = food.mealType
//        downloadImage(foodImageURL: food.imagePath)
////        downloadImage(foodImageURL: "https://httpbin.org/image/png")
//    }
//
//    mutating func downloadImage(foodImageURL: String) {
//        var result = self
//        Alamofire.request(foodImageURL).responseImage { response in
//            debugPrint(response)
//
//            print(response.request)
//            print(response.response)
//            debugPrint(response.result)
//
//            if let image = response.result.value {
//                //print("image downloaded: \(image)")
////                result.foodImage = image
//            }
//        }
//        self = result
//    }
//}
