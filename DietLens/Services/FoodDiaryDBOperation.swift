//
//  DataManager.swift
//  DietLens
//
//  Created by linby on 06/11/2017.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation
import RealmSwift

class FoodDiaryDBOperation {

    static var instance = FoodDiaryDBOperation()
    //swiftlint:disable force_try
    let realm = try! Realm()

    /// save foodDiary into realm
    ///
    /// - Parameter foodDiary: the whole foodDiary Object
    func saveFoodDiary(foodDiary: FoodDiary) {
        try! realm.write {
            realm.add(foodDiary)
        }
    }

    /// delete target foodDiary by Id
    ///
    ///  - Parameter foodDiaryId: foodDiaryId
    func deleteFoodDiary(foodDiaryId: Int) {
        try! realm.write {
            let deleteTarget = realm.objects(FoodDiary.self).filter("id=\(foodDiaryId)")
            realm.delete(deleteTarget[0])
        }
    }

    /// get all the foodDiary
    ///
    /// - Returns: array of all the foodDiary
    func getAllFoodDiary() -> [FoodDiary]? {
        var results = [FoodDiary]()
        try! realm.write {
            let foodDiarys = realm.objects(FoodDiary.self)
            for foodDiary in foodDiarys {
                results.append(foodDiary)
            }
        }
        return results
    }

    /// get foodDiary by month&year time
    ///
    /// - Parameter year: foodDiary record year
    /// - Parameter month: foodDiary record month
    /// - Returns: array of foodDiary
    func getFoodDiaryByMonth(year: String, month: String) -> [FoodDiary]? {
        var results = [FoodDiary]()
        try! realm.write {
            let foodDiarys = realm.objects(FoodDiary.self).filter("mealTime CONTAINS '\(month+year)'")
            for foodDiary in foodDiarys {
                results.append(foodDiary)
            }
        }
        return results
    }

    func getFoodDiaryByDate(date: String) -> [FoodDiary]? {
        var results = [FoodDiary]()
        try! realm.write {
//            let foodDiarys = realm.objects(FoodDiary.self).filter("mealTime='\(date)'")
//            for foodDiary in foodDiarys {
//                results.append(foodDiary)
//            }
            let foodDiarys = realm.objects(FoodDiary.self)
            for foodDiary in foodDiarys {
                if(foodDiary.mealTime == date) {
                  results.append(foodDiary)
                }
            }
        }
        return results
    }
}
