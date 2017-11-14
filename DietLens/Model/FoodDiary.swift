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
    @objc dynamic var portionSize = 1.0
    @objc dynamic var calorie = 0.0
    @objc dynamic var carbohydrate = ""
    @objc dynamic var protein = ""
    @objc dynamic var fat = ""
    @objc dynamic var category = ""
}
