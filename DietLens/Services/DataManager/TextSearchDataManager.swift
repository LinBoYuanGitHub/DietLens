//
//  TextSearchDataManager.swift
//  DietLens
//
//  Created by linby on 2018/9/22.
//  Copyright © 2018 NExT++. All rights reserved.
//

import Foundation
import SwiftyJSON

class TextSearchDataManager {

    static var instance = TextSearchDataManager()
    private init() {}

    func assembleTextSerchResultList(jsonObj: JSON) -> [TextSearchSuggestionEntity] {
        var foodSearchList = [TextSearchSuggestionEntity]()
        let jsonArr = jsonObj["data"]
        for index in 0..<jsonArr.count {
            let json = jsonArr[index]
            let entity = assembleTextSearchResultData(jsonObj: json)
            foodSearchList.append(entity)
        }
        return foodSearchList
    }

    func assembleTextSearchResultData(jsonObj: JSON) -> TextSearchSuggestionEntity {
        var entity = TextSearchSuggestionEntity()
        entity.id = jsonObj["id"].intValue
        entity.name = jsonObj["name"].stringValue
        entity.useExpImage = jsonObj["is_exp_img"].bool!
        entity.expImagePath = jsonObj["example_img"].stringValue
        entity.calorie = jsonObj["total_nutrition"]["energy"].intValue
        entity.weight = jsonObj["food_portion"][0]["weight_g"].intValue
        entity.unit = jsonObj["food_portion"][0]["measurement_type"].stringValue
        return entity
    }

    func assemblePopularTextSerchResultList(jsonObj: JSON) -> [TextSearchSuggestionEntity] {
        var foodSearchList = [TextSearchSuggestionEntity]()
        let jsonArr = jsonObj["data"]
        for index in 0..<jsonArr.count {
            let json = jsonArr[index]["food"]
            let entity = assembleTextSearchResultData(jsonObj: json)
            foodSearchList.append(entity)
        }
        return foodSearchList
    }

}
