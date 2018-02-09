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
        //autoincrease
        let nextId = getMaxIngredientId()+1
        foodDiary.id = nextId
        try! realm.write {
            realm.add(foodDiary)
        }
    }

    private func getMaxIngredientId() -> Int {
        var maxId = 1
        try! realm.write {
            if realm.objects(FoodDiary.self).count == 0 {
                maxId = 1
            } else {
                maxId = realm.objects(FoodDiary.self).max(ofProperty: "id")!
            }
        }
        return maxId
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

    //show in history food
    func getRecentAddedFoodDiary(limit: Int) -> [FoodDiary] {
        var results = [FoodDiary]()
        try! realm.write {
            let foodDiarys = realm.objects(FoodDiary.self).filter("recordType='text'").sorted(byKeyPath: "id", ascending: false)
            if foodDiarys.count > limit {
                for i in 0..<limit {
                    results.append(foodDiarys[i])
                }
            } else {
                for foodDiary in foodDiarys {
                    results.append(foodDiary)
                }
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
            let foodDiarys = realm.objects(FoodDiary.self).filter("mealTime CONTAINS '\(month+" "+year)'").sorted(byKeyPath: "mealTime", ascending: false)
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

    func deleteFoodDiary(id: Int) {
        try! realm.write {
            let deleteObj = realm.objects(FoodDiary.self).filter("id = \(id)")
            realm.delete(deleteObj)
        }
    }

//    private func saveIngredient(ingredientDiary: IngredientDiary) {
//        try! realm.write {
//            realm.add(ingredientDiary)
//        }
//    }
//
//    private func getMaxIngredientId() -> Int {
//        var maxId = 1
//        try! realm.write {
//            maxId = realm.objects(IngredientDiary.self).max(ofProperty: "id")!
//        }
//        return maxId
//    }
//
//    func getIngredientById(id: Int) -> IngredientDiary {
//        var ingredient = IngredientDiary()
//        try! realm.write {
//            let results = realm.objects(IngredientDiary.self).filter("id = \(id)")
//            ingredient = results[0]
//        }
//        return ingredient
//    }
//
//    func addIngredient(ingredientDiary: IngredientDiary) {
//        var id = getMaxIngredientId()
//        id += 1
//        ingredientDiary.id = id
//        saveIngredient(ingredientDiary: ingredientDiary)
//    }

}
