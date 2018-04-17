//
//  DisplayFoodInfo.swift
//  DietLens
//
//  Created by linby on 11/04/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import Foundation

struct DisplayFoodCategory {
    var subcatName = ""
    var subcatImageUrl = ""
    var subcateFoodList = [DisplayFoodInfo]()
}

struct DisplayFoodInfo {
    var id: Int = 0
    var displayName: String = ""
    var exampleImgUrl: String = ""
    var calories: Double = 0.0
}
