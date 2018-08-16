//
//  HealthCenterDBOperation.swift
//  DietLens
//
//  Created by linby on 17/01/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import Foundation
import RealmSwift
class HealthCenterDBOperation {
    static var instance = HealthCenterDBOperation()
    //swiftlint:disable force_try
//    let realm = try! Realm()

    /// save foodDiary into realm
    ///
    /// - Parameter foodDiary: the whole foodDiary Object
    func savehealthRecord(healthRecord: HealthRecord) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(healthRecord)
        }
    }

    func getAllHealthRecord(recordId: Int) -> [HealthRecord] {
        let realm = try! Realm()
        var results = [HealthRecord]()
        try! realm.write {
            let healthRecords = realm.objects(HealthRecord.self)
            for healthRecord in healthRecords {
                results.append(healthRecord)
            }
        }
        return results
    }

    //get TOP5 result of one recordType
    func getTopHealthRecord(recordType: String) -> [HealthRecord] {
        let realm = try! Realm()
        var results = [HealthRecord]()
        try! realm.write {
            let healthRecords = realm.objects(HealthRecord.self).filter("type = '\(recordType)' ").sorted(byKeyPath: "date", ascending: false)
            if healthRecords.count > 5 {
                for index in 0..<5 {
                    results.append(healthRecords[index])
                }
            } else {
                for healthRecord in healthRecords {
                    results.append(healthRecord)
                }
            }

        }
        return results
    }

    func getLatestResultOfRecord(recordType: String) -> HealthRecord {
        let realm = try! Realm()
        var latestRecord = HealthRecord()
        try! realm.write {
            let healthRecords = realm.objects(HealthRecord.self).filter("type = '\(recordType)' ").sorted(byKeyPath: "date", ascending: false)
            if healthRecords.count > 0 {
                latestRecord = healthRecords[0]
            }
        }
        return latestRecord
    }

}
