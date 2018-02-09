//
//  HealthRecord.swift
//  DietLens
//
//  Created by linby on 17/01/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import Foundation
import RealmSwift

class HealthRecord: Object {
    @objc dynamic var id = 0
    @objc dynamic var type = ""
    @objc dynamic var value: Float = 0.0
    @objc dynamic var unit = ""
    @objc dynamic var date = Date()
}
