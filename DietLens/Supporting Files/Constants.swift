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
    static let baseURL = "http://47.74.189.175:8001/dl/v1"  //production environment
//    static let baseURL = "http://47.88.223.32:8001/dl/v1"  //testing environment
//    static let baseURL = "http://172.29.32.226:8001/dl/v1"
    static let userURL = baseURL + "/users"
    static let userLoginURL = baseURL + "/login/"
    static let getUUidURL = baseURL + "/anonymous/"
    static let registry = baseURL + "/register/"
    static let thirdPartyLoginURL = baseURL + "/3rdlogin"

    static let acctForgetPwSendEmailURL = baseURL + "/accounts/check/"
    static let acctForgetPwEmailVerifURL = baseURL + "/accounts/verification/"
    static let acctForgetPwResetURL = baseURL + "/accounts/set-password/"

    static let articleURL = "http://47.88.223.32:8001/dl/v1" + "/article"
    static let eventURL = "http://47.88.223.32:8001/dl/v1" + "/event/"
//    static let imageUploadURL = baseURL + "/process"
    static let imageUploadURL = baseURL + "/image-search/"
    static let foodDiaryURL = baseURL + "/healthlog/diet/"
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

struct NutrtionData {
    static let calorieText = "Calorie"
    static let carbohydrateText = "Carbohydrate"
    static let proteinText = "Protein"
    static let fatText = "Fat"
    static let sugarText = "Sugar"
}

struct RecordType {
    static let RecordByImage = "recognition"
    static let RecordByBarcode = "barcode"
    static let RecordByText = "text"
    static let RecordByCustomized = "customized"
}

struct ArticleType {
    static let ARTICLE = "article"
    static let EVENT = "event"
}
