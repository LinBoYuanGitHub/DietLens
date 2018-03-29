//
//  profileDataManager.swift
//  DietLens
//
//  Created by linby on 27/01/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import Foundation
import SwiftyJSON

class ProfileDataManager {
    static var instance = ProfileDataManager()
    private init() {}

    func assembleUserProfile(jsonObj: JSON) -> UserProfile {
        var userProfile = UserProfile()
        userProfile.id = jsonObj["id"].stringValue
        userProfile.name = jsonObj["name"].stringValue
        userProfile.gender = jsonObj["gender"].intValue
        userProfile.birthday = jsonObj["birthday"].stringValue
        userProfile.age = jsonObj["age"].intValue
        userProfile.occupation = jsonObj["occupation"].stringValue
        userProfile.nationality = jsonObj["nationality"].stringValue
        userProfile.maritalStatus = jsonObj["marital_status"].stringValue
        userProfile.height = jsonObj["height"].doubleValue
        userProfile.weight = jsonObj["weight"].doubleValue
        return userProfile
    }
}
