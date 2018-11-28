///
//  ProfileEntity.swift
//  DietLens
//
//  Created by linby on 2018/6/27.
//  Copyright © 2018 NExT++. All rights reserved.
//

import Foundation

class ProfileEntity {
    var profileName: String = ""//left
    var profileValue: String = ""
    var profileType: Int = 0

    init(profileName: String, profileValue: String, profileType: Int) {
        self.profileName = profileName
        self.profileValue = profileValue
        self.profileType = profileType
    }

}
