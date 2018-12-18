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

    func assembleClinicalStudyDataEntity(jsonArr: JSON) -> [ClinicalStudyEntity] {
        var resultList = [ClinicalStudyEntity]()
        guard let array = jsonArr.array else {
            return resultList
        }
        for index in 0..<array.count {
            let json = jsonArr[index]
            let studyId = json["id"].stringValue
            let studyName = json["title"].stringValue
            var entity = ClinicalStudyEntity()
            entity.studyId = studyId
            entity.studyName = studyName
            entity.status = .pending
            resultList.append(entity)
        }
        return resultList
    }

    func assembleClinicalStudyDetailEntity(jsonObj: JSON) -> ClinicalStudyEntity {
        var entity = ClinicalStudyEntity()
        entity.studyId = jsonObj["id"].stringValue
        entity.studyName = jsonObj["title"].stringValue
        //content part
        entity.content.studyDesc = jsonObj["description"].stringValue
        entity.content.startDate = DateUtil.standardZStringToDate(dateStr: jsonObj["start_time"].stringValue)
        entity.content.endDate = DateUtil.standardZStringToDate(dateStr: jsonObj["end_time"].stringValue)
        entity.content.timeZone = jsonObj["timezone"].stringValue
        //owner part
        entity.owner.ownerId = jsonObj["owner"]["id"].stringValue
        entity.owner.email = jsonObj["owner"]["email"].stringValue
        entity.owner.nickname = jsonObj["owner"]["nickname"].stringValue
        entity.owner.organization = jsonObj["owner"]["organization"].stringValue
        entity.owner.phone = jsonObj["owner"]["phone"].stringValue
        //inclusion criteria part
        for  childJsonObj in jsonObj["inclusion_criteria"] {
            if childJsonObj.1.count == 0 {
                break
            }
            var criteria = Criteria()
            criteria.name = childJsonObj.1["name"].stringValue
            criteria.value = childJsonObj.1["value"].stringValue
            entity.inclusionCriteria.append(criteria)
        }
        //exclusion criteria part
        for childJsonObj in jsonObj["exclusion_criteria"] {
            if childJsonObj.1.count == 0 {
                break
            }
            var criteria = Criteria()
            criteria.name = childJsonObj.1["name"].stringValue
            criteria.value = childJsonObj.1["value"].stringValue
            entity.exclusionCriteria.append(criteria)
        }
        for childJsonObj in jsonObj["data_tag"] {
            if childJsonObj.1.count == 0 {
                break
            }
            var dataTag = DataTag()
            dataTag.id = childJsonObj.1["id"].stringValue
            dataTag.name = childJsonObj.1["name"].stringValue
            entity.dataTags.append(dataTag)
        }
        return entity
    }
}
