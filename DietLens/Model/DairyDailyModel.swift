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

public enum Meal: Int {
    case breakfast
    case lunch
    case dinner
}

struct FoodInfo {
    var foodName: String = ""
    var calories: Double = 0
    var imageURL: String?
    var servingSize: String = ""

    init() {
        self.foodName = ""
        self.calories = 0
        self.imageURL = ""
        self.servingSize = ""
    }

    init(food: FoodDiary) {
        self.foodName = food.foodName
        self.calories = food.calorie
        self.servingSize = String(food.portionSize)
        downloadImage(foodImageURL: food.imagePath)
//        downloadImage(foodImageURL: "https://httpbin.org/image/png")
    }

    mutating func downloadImage(foodImageURL: String) {
        var result = self
        Alamofire.request(foodImageURL).responseImage { response in
            debugPrint(response)

            print(response.request)
            print(response.response)
            debugPrint(response.result)

            if let image = response.result.value {
                //print("image downloaded: \(image)")
//                result.foodImage = image
            }
        }
        self = result
    }
}

struct DiaryDailyFood {
    var mealOfDay: Meal = .breakfast
    var foodConsumed = [FoodInfo]()
}
