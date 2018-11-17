//
//  userProfile.swift
//  DietLens
//
//  Created by linby on 27/01/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import Foundation

struct UserProfile {
    var id: String = ""
    var name: String = ""
    var email: String = ""
    var phone: String = ""
    var gender: Int = 2
    var birthday: String = ""
    var age: Int = 0
    var occupation: String = ""
    var nationality: String = ""
    var maritalStatus: String = ""
    var height: Double = 0.0
    var weight: Double = 0.0
    var activityLevel: Int = 0
    var ethnicity = 0
    var dietGoal = DietGoal()
}

struct DietGoal {
    var calorie: Double = 0
}
