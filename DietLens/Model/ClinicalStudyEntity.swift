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
}

struct StudyContent {
    var startDate = Date()
    var endDate = Date()
    var studyDesc = ""
    var authorInfo = ""
    var contactInfo = ""
}

enum StudyStatus {
    case pending
    case process
    case completed
    case expiry
}
