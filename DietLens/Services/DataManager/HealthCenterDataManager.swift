//
//  HealthCenterDataManager.swift
//  DietLens
//
//  Created by linby on 2018/7/9.
//  Copyright © 2018 NExT++. All rights reserved.
//

import Foundation
import SwiftyJSON

class HealthCenterDataManager {

    static var instance = HealthCenterDataManager()
    private init() {}

    func assembleHealthCenterMainData(jsonObj: JSON) -> [HealthCenterItem] {
        var healthCenterList = [HealthCenterItem]()
        var weight = assembleSingleHealthCenterData(jsonObj: jsonObj["weight"])
        weight.itemName = "weight"
        weight.type = "0"
        var glucose = assembleSingleHealthCenterData(jsonObj: jsonObj["glucose"])
        glucose.itemName = "glucose"
        glucose.type = "1"
        var mood = assembleSingleHealthCenterData(jsonObj: jsonObj["mood"])
        mood.itemName = "mood"
        mood.type = "2"
        //append list
        healthCenterList.append(weight)
        healthCenterList.append(glucose)
        healthCenterList.append(mood)
        return healthCenterList
    }

    func assembleSingleHealthCenterData(jsonObj: JSON) -> HealthCenterItem {
        var record = HealthCenterItem()
        record.id = jsonObj["id"].stringValue
        record.category = jsonObj["category"].stringValue
        record.value = jsonObj["value"].floatValue
        record.date = jsonObj["date"].stringValue
        record.time = jsonObj["time"].stringValue
        return record
    }

    func assembleHealthCenterItem(jsonArr: JSON) -> [HealthCenterItem] {
        var itemList = [HealthCenterItem]()
        for index in 0..<jsonArr.count {
            let jsonObj = jsonArr[index]
            let healcenterObj =  assembleSingleHealthCenterData(jsonObj: jsonObj)
            itemList.append(healcenterObj)
        }
        return itemList
    }
}
