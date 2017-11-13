//
//  DairyDailyModel.swift
//  DietLens
//
//  Created by next on 7/11/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation
import UIKit

public enum Meal: Int {
    case breakfast
    case lunch
    case dinner
}

struct FoodInfo {
    var foodName: String = ""
    var calories: Double = 0
    var foodImage: UIImage?
    var servingSize: String = ""
}

struct DiaryDailyFood {
    var mealOfDay: Meal = .breakfast
    var foodConsumed = [FoodInfo]()
}
