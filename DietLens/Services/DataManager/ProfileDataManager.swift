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
        userProfile.email = jsonObj["user"].stringValue
        userProfile.gender = Int(jsonObj["gender"].stringValue)!
        userProfile.phone = jsonObj["phone"].stringValue
//        if jsonObj["gender"].stringValue == "1"{
//            userProfile.gender = 1
//        } else {
//             userProfile.gender = 0
//        }
        userProfile.activityLevel = Int(jsonObj["activity_level"].stringValue)!
        userProfile.birthday = jsonObj["birthday"].stringValue
        userProfile.age = jsonObj["age"].intValue
        userProfile.occupation = jsonObj["occupation"].stringValue
        userProfile.nationality = jsonObj["nationality"].stringValue
        userProfile.maritalStatus = jsonObj["marital_status"].stringValue
        userProfile.height = jsonObj["height"].doubleValue
        userProfile.weight = jsonObj["weight"].doubleValue
        userProfile.ethnicity = jsonObj["ethnicity"].intValue
        return userProfile
    }

    func cacheUserProfile(profile: UserProfile) {
        let preference = UserDefaults.standard
        preference.set(profile.id, forKey: PreferenceKey.ProfileCache.profileId)
        preference.set(profile.email, forKey: PreferenceKey.ProfileCache.profileEmail)
        preference.set(profile.gender, forKey: PreferenceKey.ProfileCache.profileGender)
        preference.set(profile.name, forKey: PreferenceKey.ProfileCache.profileNickName)
        preference.set(profile.birthday, forKey: PreferenceKey.ProfileCache.profileBirthday)
        preference.set(profile.height, forKey: PreferenceKey.ProfileCache.profileHeight)
        preference.set(profile.weight, forKey: PreferenceKey.ProfileCache.profileWeight)
        preference.set(profile.activityLevel, forKey: PreferenceKey.ProfileCache.profileAcivityLevel)
        preference.set(profile.ethnicity, forKey: PreferenceKey.ProfileCache.profileEthnicity)
    }

    func getCachedProfile() -> UserProfile {
        let preference = UserDefaults.standard
        var profile = UserProfile()
        profile.id = preference.string(forKey: PreferenceKey.ProfileCache.profileId)!
        profile.name = preference.string(forKey: PreferenceKey.ProfileCache.profileNickName)!
        profile.birthday = preference.string(forKey: PreferenceKey.ProfileCache.profileBirthday)!
        profile.email = preference.string(forKey: PreferenceKey.ProfileCache.profileEmail)!
        profile.height = preference.double(forKey: PreferenceKey.ProfileCache.profileHeight)
        profile.weight = preference.double(forKey: PreferenceKey.ProfileCache.profileWeight)
        profile.gender = preference.integer(forKey: PreferenceKey.ProfileCache.profileGender)
        profile.ethnicity = preference.integer(forKey: PreferenceKey.ProfileCache.profileEthnicity)
        return profile
    }
}
