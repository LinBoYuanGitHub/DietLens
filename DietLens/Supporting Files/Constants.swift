//
//  Constants.swift
//  DietLens
//
//  Created by next on 27/10/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation

struct ServerConfig {

//    static let baseURL = "http://137.132.179.21:8000"
//    static let userLoginURL = baseURL + "/login/"
//    static let getUUidURL = baseURL + "/uuid/"
//    static let registry = baseURL + "/registry/"
//    static let thirdPartyLoginURL = baseURL + "/3rdlogin/"
//
//    static let articleURL = baseURL + "/article/"
//    static let imageUploadURL = baseURL + "/process/"
//    static let saveFoodDiaryURL = baseURL + "/photolist/"
//    static let foodSearchListURL = baseURL + "/text/"
//    static let foodSearchDetailURL = baseURL + "/textinfo/"
//    static let barcodeSearchURL = baseURL + "/barcode/"

    //testing environment

//    static let baseURL = "http://dl.dietlens.com:8000/dl/v1"
    static let baseURL = "http://47.74.189.175:8001/dl/v1"
//    static let baseURL = "http://172.29.32.226:8000/dl/v1"
    static let userURL = baseURL + "/users"
    static let userLoginURL = baseURL + "/login/"
    static let getUUidURL = baseURL + "/anonymous/"
    static let registry = baseURL + "/register/"
    static let thirdPartyLoginURL = baseURL + "/3rdlogin"

    static let articleURL = baseURL + "/article"
    static let eventURL = baseURL + "/event/"
//    static let imageUploadURL = baseURL + "/process"
    static let imageUploadURL = baseURL + "/image-search/"
    static let saveFoodDiaryURL = baseURL + "/healthlog/diet/"
    static let saveStepDiaryURL = baseURL + "/healthlog/steps/"
    static let saveHealthCenterDataURL = baseURL + "/healthlog/Medical/"
    static let foodSearchListURL = baseURL + "/text-search/"
    static let ingredientSearchURL = baseURL + "/ingre-search/"
    static let barcodeSearchURL = baseURL + "/barcode-search/"
    static let feedBackURL = baseURL + "/feedback/"
    static let NotificationURL = baseURL + "/notification"
}

struct SharedPreferenceKey {
    static let textSearchHistoryKey = "textSearchKey"
}
