//
//  ReportEntity.swift
//  DietLens
//
//  Created by linby on 21/12/2017.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation

struct ReportEntity {
    public var name: String = ""
    public var value: String = ""
    public var standard: String = ""

    init(name: String, value: String, standard: String) {
        self.name = name
        self.value = value
        self.standard = standard
    }
}
