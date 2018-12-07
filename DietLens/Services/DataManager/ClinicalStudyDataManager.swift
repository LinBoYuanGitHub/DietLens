//
//  ClinicalStudyDataManager.swift
//  DietLens
//
//  Created by boyuan lin on 7/12/18.
//  Copyright © 2018 NExT++. All rights reserved.
//

import Foundation
import SwiftyJSON

class ClinicalStudyDataManager {
    static var instance  = ClinicalStudyDataManager()
    private init() {}

    func assembleClinicalStudyDataEntity(jsonObj: JSON) -> [ClinicalStudyEntity] {
        var resultList = [ClinicalStudyEntity]()
        let jsonArr = jsonObj["data"]
        for index in 0..<jsonArr.count {
            let json = jsonArr[index]
            let studyId = json["studyId"].stringValue
            let studyName = json["studyName"].stringValue
            let startDate =  DateUtil.normalStringToDate(dateStr: json["startDate"].stringValue)
            let entity = ClinicalStudyEntity.init(studyId: studyId, studyName: studyName, startDate: startDate, status: .pending)
            resultList.append(entity)
        }
        return resultList
    }
}
