//
//  MockedUpFoodData.swift
//  DietLens
//
//  Created by linby on 11/04/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import Foundation
import SwiftyJSON

class MockedUpFoodData {

    static var instance = MockedUpFoodData()

    private init() {

    }

    public func assembleFoodInfoData(data: JSON) -> [DisplayFoodCategory] {
        var resultList = [DisplayFoodCategory]()
        var bestMatchCategory = DisplayFoodCategory()
        let bestMatchs = data["best_match"].arrayValue
        let subcats = data["subcat"].arrayValue
        for bestMatch in bestMatchs {
            var match = DisplayFoodInfo()
            match.id = bestMatch["id"].intValue
            match.displayName = bestMatch["display_name"].stringValue
            match.exampleImgUrl = bestMatch["example_img"].stringValue
            match.calories = bestMatch["nutrition"]["calories"].doubleValue
            bestMatchCategory.subcateFoodList.append(match)
        }
        bestMatchCategory.subcatName = "Best Match" //insert a sample Image that controll by the backend will be better
        bestMatchCategory.subcatImageUrl = ""
        resultList.append(bestMatchCategory)
        for subcat in subcats {
            var subCategory = DisplayFoodCategory()
            let foodInfos = subcat["food_info"].arrayValue
            subCategory.subcatImageUrl = subcat["subcat_image"].stringValue
            subCategory.subcatName = subcat["subcat"].stringValue
            for foodInfo in foodInfos {
                var foodObject = DisplayFoodInfo()
                foodObject.id = foodInfo["id"].intValue
                foodObject.displayName = foodInfo["display_name"].stringValue
                foodObject.exampleImgUrl = foodInfo["example_img"].stringValue
                foodObject.calories = foodInfo["nutrition"]["calories"].doubleValue
                subCategory.subcateFoodList.append(foodObject)
            }
            resultList.append(subCategory)
        }
        return resultList
    }

    public func createMockedUpFoodData() -> [DisplayFoodCategory] {
        var resultList = [DisplayFoodCategory]()
        var bestMatch = DisplayFoodCategory()
        bestMatch.subcatName = "best_match"
        bestMatch.subcateFoodList = [DisplayFoodInfo]()
        var waterMelon = DisplayFoodInfo()
        waterMelon.id = 125
        waterMelon.displayName = "Watermelon"
        waterMelon.exampleImgUrl = "http://137.132.179.21:8002/media/sampleImage/125.png"
        waterMelon.calories = 37.1
        bestMatch.subcateFoodList.append(waterMelon)
        var Guava = DisplayFoodInfo()
        Guava.id = 2
        Guava.displayName = "Guava"
        Guava.exampleImgUrl = "http://137.132.179.21:8002/media/sampleImage/2.png"
        Guava.calories = 46
        bestMatch.subcateFoodList.append(Guava)
        resultList.append(bestMatch)
        //subcat1
        var subcat1 = DisplayFoodCategory()
        subcat1.subcatName = "Fruit"
        subcat1.subcatImageUrl = "http://137.132.179.21:8002/media/sampleImage/125.png"
        subcat1.subcateFoodList = [DisplayFoodInfo]()
        subcat1.subcateFoodList.append(waterMelon)
        subcat1.subcateFoodList.append(Guava)
        resultList.append(subcat1)
        //subcat2
        var subcat2 = DisplayFoodCategory()
        subcat2.subcatName = "Salad"
        subcat2.subcatImageUrl = "http://137.132.179.21:8002/media/sampleImage/2.png"
        subcat2.subcateFoodList = [DisplayFoodInfo]()
        subcat2.subcateFoodList.append(waterMelon)
        subcat2.subcateFoodList.append(Guava)
        resultList.append(subcat2)
        return resultList
    }

}
