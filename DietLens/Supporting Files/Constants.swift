//
//  Constants.swift
//  DietLens
//
//  Created by next on 27/10/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation
import UIKit

struct ServerConfig {

    //testing environment

//    static let baseURL = "http://dl.dietlens.com:8000/dl/v1"
    static let baseURL = "http://47.74.189.175:8001/dl/v1"  //production environment
    static let testBaseURL = "http://47.88.223.32:8001/dl/v1"  //testing environment
//    static let labDeskTopURL = "http://47.88.223.32:8002/dl/v1"
    static let labDeskTopURL = "http://172.29.32.226:8000/dl/v1" //cyrus local
//    static let labDeskTopURL = "https://backend.dietlens.com/dl/v1"
//    static let labDeskTopURL = "http://54.169.160.107:8000/dl/v1" //mocklet test environment

    static let userURL = labDeskTopURL + "/users"
    static let saveNotificationTokenURL = labDeskTopURL + "/users/device/"
    static let logOutURL = labDeskTopURL + "/users/logout/"
    static let userLoginURL = labDeskTopURL + "/users/login/"
    static let registry = labDeskTopURL + "/users/register/"
    static let checkEmailURL = labDeskTopURL + "/users/email-check/"
    static let facebookIdValidationURL = labDeskTopURL + "/social-acc/facebook/"
    static let googleIdValidationURL = labDeskTopURL + "/social-acc/google/"

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
    static let foodFullTextSearchURL = labDeskTopURL + "/foodinfo/full-text/"
    static let foodSearchAutocompleteURL = labDeskTopURL + "/search/autocomplete/"
    static let ingredientSearchURL = baseURL + "/ingre-search/"
    static let barcodeSearchURL = baseURL + "/barcode-search/"
    static let feedBackURL = labDeskTopURL + "/feedback/email/"
    static let uploadRecognitionURL = "http://172.29.32.226:8000/dl/v1/foodrecognition/photo/"
//    static let uploadImageKeyURL = "http://172.29.31.44:8003/webHook"
    static let uploadImageKeyURL = labDeskTopURL+"/foodinfo/recognition/"
    //health center log
    static let uploadHealthCenterData = labDeskTopURL + "/healthlogs/"
    //foodDiary CRUD
    static let foodDiaryOperationURL = labDeskTopURL + "/foodinfo/"
    static let foodDiaryDietLogs = labDeskTopURL + "/dietlogs/"
    static let foodDiaryDeleteAll = labDeskTopURL + "/dietlogs/delete-logs/"
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

    static let healthCenterLogURL = labDeskTopURL + "/healthlogs/latest/"
    static let qiniuDietLensImageDomain = "https://img.dietlens.com/"
    static let textSearchPopularURL = labDeskTopURL + "/popular-food/"
    static let favouriteFoodURL = labDeskTopURL + "/favorite-food/"
//    static let qiniuDietLensImageDomain = "https://image.dietlens.com/"
    static let phoneSendSMSURL = labDeskTopURL + "/social-acc/sms/"
    static let verifySMSURL = labDeskTopURL + "/social-acc/phone/"
    static let dietGoalURL = labDeskTopURL + "/diet-goal/"
}

struct RedirectAddress {
    static let AppStoreURL = "https://itunes.apple.com/us/app/dietlens/id1415528218"
    static let DietLensURL = "https://www.dietlens.com"
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
//    static let scope = "dietlog"
//    static let accessKey = "ExTDSVzfUQiu0wwJXBzXLg_PxNQxbb3tkC4UpyB6"
//    static let secretKey = "8u_GKcaQWMD3L-94OdG8P_o9b8SGqAIjYFoX953A"
    static let rootDomain = "p7bqh4trt.sabkt.gdipper.com"
    //south east service
    static let scope = "diet-img"
    static let accessKey = "hr3zme-bt6vJBpunS4FH5Tbt9mWE3QGmTftNBjNK"
    static let secretKey = "-uVeMoW24RqTwQvCyWlpUdrVi7WNEAeI1eptbx1W"
//     static let scope = "dietlens" //private scope
//    static let rootDomain = "http://p7bnhf5so.sabkt.gdipper.com" //private domain
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
    static let facebookId = "facebookId"
    static let googleUserId = "googleId"
    static let googleImageUrl = "googleImageUrl"
    static let userIdkey = "userId"
    static let fcmTokenKey = "FCMTOKEN"
    static let stepUploadLatestTime = "stepUploadKey"
    static let nickNameKey = "nickname"
    static let userNameKey = "username"
    static let passwordKey = "password"
    static let saveToAlbumFlag = "saveToAlbumFlag"

    struct ProfileCache {
        static let profileId = "profileId"
        static let profileNickName = "profileNickName"
        static let profileEmail = "profileEmail"
        static let profileGender = "profileGender"
        static let profileAcivityLevel = "profileActivityLevel"
        static let profileBirthday = "profileBirthday"
        static let profileHeight = "prifileHeight"
        static let profileWeight = "profileWeight"
        static let profileEthnicity = "profileEthnicity"
    }
}

struct Dimen {
    static let NewsFeedTableHeight = 198
    static let NewsArticleCollectionHeight = 220
    static let EventsFirstRowHeight = 310
    static let EventsRowHeight = 275
    static let foodCalendarImageWidth = 68
    static let foodCalendarImageHeight = 68
}

struct HealthCenterConstants {
    static let moodList = ["Bad", "Not so good", "Ok", "Happy", "Excellent"]
    static let GLUCOSEDEFAULT = 60
    static let WEIGHTDEFAULT = 60
}

struct NotificationType {
    static let NoneType = "0"
    static let SingleOptionType = "1"
    static let checkBoxType = "2"
    static let TextFieldType = "3"
    static let Rating4StarType = "4"
    static let Rating7StarType = "5"
}

struct EthnicityType {
    static let NONE = 0
    static let CHINESE = 1
    static let MALAYS = 2
    static let INDIANS = 3
    static let OTHERS = 4
}

struct BirthDayLimitation {
    static let minAge = 10
    static let maxAge = 100
}

struct HealthDeviceSetting {
    static let minHeight = 50
    static let maxHeight = 300
    static let minWeight = 5
    static let maxWeight = 300
    static let minBloodGlucose = 1
    static let maxBloodGlucose = 100
}

struct DietGoalTreshold {
    static let minCalorieGoalValue = 1000
    static let maxCalorieGoalValue = 4000
}

struct FirstTimeFlag {
    static let isFirstTimeLogin = "isFirstTimeLogin" //show IntroductionPage
    static let isFirstTimeViewAddMore = "isFirstTimeAddMore" //show addMore coach mark
    static let isNotFirstTimeViewHome = "isFirstTimeViewHome" //show camera coach mark
    static let isFirstTimeViewRecogResult = "isFirstTimeViewRecogResult" //show recogResult coach mark
    static let isNotFirstTimeViewMixFood = "isFirstTimeViewMixFood" //show mix food coach mark
    static let shouldPopUpProfilingDialog = "shouldPopUpProfilingDialog" //should pop up profiling dialog

}

struct MessageType {
    static let messageType = "0"
    static let questionnaireType = "1"
}

extension UIColor {
    struct ThemeColor {
        static let dietLensRed = UIColor(displayP3Red: CGFloat(242.0/255.0), green: CGFloat(63.0/255.0), blue: CGFloat(93.0/255.0), alpha: 1.0)
    }

}
