//
//  HealthCenterRecord.swift
//  DietLens
//
//  Created by linby on 2018/6/29.
//  Copyright © 2018 NExT++. All rights reserved.
//

import Foundation

class HealthCenterRecord {
    var id = 0
    var type = ""
    var itemName = ""
    var value: Float = 0.0
    var unit = ""
    var date = Date()

    init(type: String, itemName: String, value: Float, unit: String, date: Date) {
        self.type = type
        self.itemName = itemName
        self.value = value
        self.unit = unit
        self.date = date
    }
}
