//
//  SearchSuggestionEntity.swift
//  DietLens
//
//  Created by linby on 11/11/2017.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation

struct TextSearchSuggestionEntity {
    public var id: Int = 0
    public var name: String = ""
    public var useExpImage: Bool = false
    public var expImagePath = ""

    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }

    init(id: Int, name: String, useExpImage: Bool, expImagePath: String) {
        self.id = id
        self.name = name
        self.useExpImage = useExpImage
        self.expImagePath = expImagePath
    }

}
