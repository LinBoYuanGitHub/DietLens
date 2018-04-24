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
    static let testBaseURL = "http://47.88.223.32:8001/dl/v1"  //testing environment
    static let labDeskTopURL = "http://172.29.32.226:8000/dl/v1"
    static let userURL = baseURL + "/users"
    static let userLoginURL = baseURL + "/login/"
    static let getUUidURL = baseURL + "/anonymous/"
    static let registry = baseURL + "/register/"
    static let thirdPartyLoginURL = baseURL + "/3rdlogin"

    static let acctForgetPwSendEmailURL = baseURL + "/accounts/check/"
    static let acctForgetPwEmailVerifURL = baseURL + "/accounts/verification/"
    static let acctForgetPwResetURL = baseURL + "/accounts/set-password/"

    static let articleURL = testBaseURL + "/article"
    static let eventURL = testBaseURL + "/event/"
//    static let imageUploadURL = baseURL + "/process"
    static let imageUploadURL = baseURL + "/image-search/"
    static let foodDiaryURL = baseURL + "/healthlog/diet/"
    static let saveStepDiaryURL = baseURL + "/healthlog/steps/"
    static let saveHealthCenterDataURL = baseURL + "/healthlog/Medical/"
    static let foodSearchListURL = labDeskTopURL + "/search/text/"
    static let foodSearchAutocompleteURL = labDeskTopURL + "/search/autocomplete/"
    static let ingredientSearchURL = baseURL + "/ingre-search/"
    static let barcodeSearchURL = baseURL + "/barcode-search/"
    static let feedBackURL = baseURL + "/feedback/"
    static let NotificationURL = baseURL + "/notification"
    static let uploadRecognitionURL = "http://172.29.32.226:8000/dl/v1/foodrecognition/photo/"
    static let uploadImageKeyURL = "http://172.29.33.83:8003/webHook"
    //foodDiary CRUD
    static let foodDiaryOperationURL = labDeskTopURL + "/foodinfo/"
    static let foodDiaryDietLogs = labDeskTopURL + "/dietlogs/"
    static let foodDiaryDietItems = labDeskTopURL + "/delete-detail/"
    static let foodDiaryCalendar = labDeskTopURL + "/dietlogs/calendar/"
    static let dietaryGuideURL = labDeskTopURL + "/users/dietary-guide/"
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

struct QiniuConfig {
    static let scope = "dietlens"
    static let accessKey = "ExTDSVzfUQiu0wwJXBzXLg_PxNQxbb3tkC4UpyB6"
    static let secretKey = "8u_GKcaQWMD3L-94OdG8P_o9b8SGqAIjYFoX953A"
    static let rootDomain = "http://p7bnhf5so.sabkt.gdipper.com"
}

struct RecordType {
    static let RecordByImage = "recognition"
    static let RecordByBarcode = "barcode"
    static let RecordByText = "text"
    static let RecordByCustomized = "customized"
}

struct RecognitionInteger {
    static let recognition = "0"
    static let text = "1"
    static let gallery = "2"
    static let barcode = "3"
}

struct ArticleType {
    static let ARTICLE = "article"
    static let EVENT = "event"
}

struct Dimen {
    static let NewsFeedTableHeight = 198
    static let NewsArticleCollectionHeight = 220
    static let EventsFirstRowHeight = 310
    static let EventsRowHeight = 275
}
