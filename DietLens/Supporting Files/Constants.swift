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
//    static let labDeskTopURL = "http://47.88.223.32:8002/dl/v1"
//    static let labDeskTopURL = "http://172.29.32.226:8000/dl/v1" //cyrus local
//    static let labDeskTopURL = "https://backend.dietlens.com/dl/v1"
    static let labDeskTopURL = "http://54.169.160.107:8000/dl/v1" //mocklet test environment

    static let userURL = labDeskTopURL + "/users"
    static let saveNotificationTokenURL = labDeskTopURL + "/users/device/"
    static let logOutURL = labDeskTopURL + "/users/logout/"
    static let userLoginURL = labDeskTopURL + "/users/login/"
    static let registry = labDeskTopURL + "/users/register/"

    static let getUUidURL = baseURL + "/anonymous/"
    static let thirdPartyLoginURL = baseURL + "/3rdlogin"
    static let acctForgetPwSendEmailURL = baseURL + "/accounts/check/"
    static let acctForgetPwEmailVerifURL = baseURL + "/accounts/verification/"
    static let acctForgetPwResetURL = baseURL + "/accounts/set-password/"
    static let forgetPwdUrl = labDeskTopURL + "/users/forgot-password/"

    static let articleURL = labDeskTopURL + "/articles"
    static let eventURL = labDeskTopURL + "/events/"
//    static let imageUploadURL = baseURL + "/process"
    static let imageUploadURL = baseURL + "/image-search/"
    static let foodDiaryURL = baseURL + "/healthlog/diet/"
    static let saveStepDiaryURL = baseURL + "/healthlog/steps/"
    static let saveHourlyStepURL = labDeskTopURL+"/steps/"
    static let saveHealthCenterDataURL = baseURL + "/healthlog/Medical/"
    static let foodSearchListURL = labDeskTopURL + "/search/auto-suggestion/"
    static let foodFullTextSearchURL = labDeskTopURL + "/search/full-text/"
    static let foodSearchAutocompleteURL = labDeskTopURL + "/search/autocomplete/"
    static let ingredientSearchURL = baseURL + "/ingre-search/"
    static let barcodeSearchURL = baseURL + "/barcode-search/"
    static let feedBackURL = labDeskTopURL + "/feedback/email/"
    static let uploadRecognitionURL = "http://172.29.32.226:8000/dl/v1/foodrecognition/photo/"
//    static let uploadImageKeyURL = "http://172.29.31.44:8003/webHook"
    static let uploadImageKeyURL = "https://recognize.dietlens.com/webHook"
    //foodDiary CRUD
    static let foodDiaryOperationURL = labDeskTopURL + "/foodinfo/"
    static let foodDiaryDietLogs = labDeskTopURL + "/dietlogs/"
    static let foodDiaryDietItems = labDeskTopURL + "/dietlogs/delete-detail/"
    static let foodDiaryCalendar = labDeskTopURL + "/dietlogs/calendar/"
    //get nutrition sum
    static let dietaryGuideURL = labDeskTopURL + "/users/dietary-guide/"
    static let nutritionSum = labDeskTopURL + "/dietlogs/sum/"
    static let nutritionDailySum = labDeskTopURL + "/dietlogs/daily-sum/"
    //notification part
    static let notificationURL = labDeskTopURL + "/notifications/"
    static let notificationDeleteAllURL = labDeskTopURL + "/notifications/all/"
    static let notificationAnswer = labDeskTopURL + "/answers/"
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
    static let scope = "dietlog"
    static let accessKey = "ExTDSVzfUQiu0wwJXBzXLg_PxNQxbb3tkC4UpyB6"
    static let secretKey = "8u_GKcaQWMD3L-94OdG8P_o9b8SGqAIjYFoX953A"
    static let rootDomain = "p7bqh4trt.sabkt.gdipper.com"
//     static let scope = "dietlens" //private scope
//    static let rootDomain = "http://p7bnhf5so.sabkt.gdipper.com" //private domain
}

struct RecordType {
    static let RecordByImage = "recognition"
    static let RecordByBarcode = "barcode"
    static let RecordByText = "text"
    static let RecordByAdditionText = "additionaltext"
    static let RecordByCustomized = "customized"
}

struct RecognitionInteger {
    static let recognition = "0"
    static let text = "1"
    static let gallery = "2"
    static let barcode = "3"
    static let additionText = "4"
}

struct TextSearchFilterInterger {
    static let allType = 0
    static let ingredientType = 1
    static let sideDish = 2
}

struct ArticleType {
    static let ARTICLE = "article"
    static let EVENT = "event"
}

struct PreferenceKey {
    static let calorieTarget = "calorieTarget"
    static let carbohydrateTarget = "carbohydrateTarget"
    static let proteinTarget = "proteinTarget"
    static let fatTarget = "fatTarget"
    static let tokenKey = "TOKEN"
    static let userIdkey = "userId"
    static let stepUploadLatestTime = "stepUploadKey"
}

struct Dimen {
    static let NewsFeedTableHeight = 198
    static let NewsArticleCollectionHeight = 220
    static let EventsFirstRowHeight = 310
    static let EventsRowHeight = 275
    static let foodCalendarImageWidth = 84
    static let foodCalendarImageHeight = 100
}

struct NotificationType {
    static let NoneType = "0"
    static let SingleOptionType = "1"
    static let checkBoxType = "2"
    static let TextFieldType = "3"
    static let Rating4StarType = "4"
    static let Rating7StarType = "5"
}
