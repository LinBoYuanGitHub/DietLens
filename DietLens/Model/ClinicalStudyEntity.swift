//
//  ClinicalStudyEntity.swift
//  DietLens
//
//  Created by boyuan lin on 7/12/18.
//  Copyright © 2018 NExT++. All rights reserved.
//

import Foundation

struct ClinicalStudyEntity {
    var studyId = ""
    var studyName = ""
    var status = StudyStatus.pending
    var content = StudyContent()
    var owner = StudyOwner()
    var inclusionCriteria = [Criteria]()
    var exclusionCriteria = [Criteria]()
    var dataTags  = [DataTag]()

    init() {}

    init (studyId: String, studyName: String, status: StudyStatus) {
        self.studyId = studyId
        self.studyName = studyName
        self.status = status
    }
}

struct StudyContent {
    var startDate = Date()
    var endDate = Date()
    var studyDesc = ""
    var timeZone = ""
}

struct StudyOwner {
    var ownerId = ""
    var nickname = ""
    var email = ""
    var phone = ""
    var organization = ""
}

struct Criteria {
    var name = ""
    var value = ""
}

struct DataTag {
    var id = ""
    var name = ""
}

enum StudyStatus {
    case pending
    case process
    case completed
    case expiry
}
