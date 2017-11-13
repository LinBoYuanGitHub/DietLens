//
//  DataService.swift
//  DietLens
//
//  Created by next on 24/10/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation

class DataService {
    static var instance = DataService()
    var screenUserIsIn: Int = 0

    private init() {
        
    }

    func test() {
        print("me")
    }
}
