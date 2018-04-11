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
    func saveFoodDiary(foodDiaryModel: FoodDiaryModel) {
//        //autoincrease
//        let nextId = getMaxIngredientId()+1
//        foodDiary.id = nextId
        try! realm.write {
            let foodDiary = foodDiaryModel.convertToStorage()
            realm.add(foodDiary)
        }
    }

    func updateFoodDiary(foodDiaryModel: FoodDiaryModel) {
        try! realm.write {
            //convert model to storage
            let replacedObj = foodDiaryModel.convertToStorage()
            realm.add(replacedObj, update: true)
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
    func getAllFoodDiary() -> [FoodDiaryModel]? {
        var results = [FoodDiaryModel]()
        try! realm.write {
            let foodDiarys = realm.objects(FoodDiary.self)
            for foodDiary in foodDiarys {
                var foodDiaryModel = FoodDiaryModel()
                foodDiaryModel.convertToObject(foodDiary: foodDiary)
                results.append(foodDiaryModel)
            }
        }
        return results
    }

    //show in history food
    func getRecentAddedFoodDiary(limit: Int) -> [FoodDiaryModel] {
        var results = [FoodDiaryModel]()
        try! realm.write {
            let foodDiarys = realm.objects(FoodDiary.self).filter("recordType='text'").sorted(byKeyPath: "id", ascending: false)
            if foodDiarys.count > limit {
                for i in 0..<limit {
                    let foodDiary = foodDiarys[i]
                    var foodDiaryModel = FoodDiaryModel()
                    foodDiaryModel.convertToObject(foodDiary: foodDiary)
                    results.append(foodDiaryModel)
                }
            } else {
                for foodDiary in foodDiarys {
                    var foodDiaryModel = FoodDiaryModel()
                    foodDiaryModel.convertToObject(foodDiary: foodDiary)
                    results.append(foodDiaryModel)
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
    func getFoodDiaryByMonth(year: String, month: String) -> [FoodDiaryModel]? {
        var results = [FoodDiaryModel]()
        try! realm.write {
            let foodDiarys = realm.objects(FoodDiary.self).filter("mealTime CONTAINS '\(month+" "+year)'").sorted(byKeyPath: "mealTime", ascending: false)
            for foodDiary in foodDiarys {
                var foodDiaryModel = FoodDiaryModel()
                foodDiaryModel.convertToObject(foodDiary: foodDiary)
                results.append(foodDiaryModel)
            }
        }
        return results
    }

    func getFoodDiaryByDate(date: String) -> [FoodDiaryModel]? {
        var results = [FoodDiaryModel]()
        try! realm.write {
            let foodDiarys = realm.objects(FoodDiary.self)
            for foodDiary in foodDiarys where foodDiary.mealTime == date {
                var foodDiaryModel = FoodDiaryModel()
                foodDiaryModel.convertToObject(foodDiary: foodDiary)
                results.append(foodDiaryModel)
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

    func getFoodDiaryById(id: Int) -> FoodDiary {
        var records: Results<FoodDiary>!
        try! realm.write {
            records = realm.objects(FoodDiary.self).filter("id = \(id)")
        }
        return records[0]
    }

}
