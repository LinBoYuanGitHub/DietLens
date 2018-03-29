//
//  FoodDiaryDataManager.swift
//  DietLens
//
//  Created by linby on 08/11/2017.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation
import RealmSwift

class FoodDiaryDataManager {

    static var instance = FoodDiaryDataManager()

    public var mealEntity = [DiaryDailyFood]()
    public var foodDiaryList = [FoodDiaryModel]()

    private var foodDiaryDBOperation = FoodDiaryDBOperation.instance

    init() {

    }

}
