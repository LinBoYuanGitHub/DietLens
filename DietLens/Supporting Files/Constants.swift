//
//  Constants.swift
//  DietLens
//
//  Created by next on 27/10/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation

struct ServerConfig {
    static let baseURL = "http://137.132.179.21:8000"
    static let userLoginURL = baseURL + "/login/"
    static let thirdPartyLoginURL = baseURL + "/3rdlogin/"
    static let userRegisterURL = baseURL + "/register/"
    static let articleURL = baseURL + "/article/"
    static let imageUploadURL = baseURL + "/process/"
    static let saveFoodDiaryURL = baseURL + "/photolist/"
    static let foodSearchListURL = baseURL + "/text/"
    static let foodSearchDetailURL = baseURL + "/textinfo/"
    static let barcodeSearchURL = baseURL + "/barcode/"
}
