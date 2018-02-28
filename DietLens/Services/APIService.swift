//
//  APIService.swift
//  DietLens
//
//  Created by linby on 11/11/2017.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class APIService {
    static var instance = APIService()
    private init() {

    }

    public func getUUIDRequest(userId: String, completion: @escaping (_ userId: String) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.getUUidURL)!,
            method: .post,
            parameters: ["id": userId],
            encoding: JSONEncoding.default,
            headers: [:])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("request UUID Failed due to : \(String(describing: response.result.error))")
                    completion("")
                    return
                }
                guard let value = response.result.value else {
                    print("Login Failed due to : Server Data Type Error")
                    completion("")
                    return
                }
                let jsonObj = JSON(value)
                if jsonObj["status"].stringValue == "HTTP_200_OK"{
                     let userId = jsonObj["data"]["id"].stringValue
                    completion(userId)
                } else {
                    completion("")
                }

        }
    }

    public func resetPwRequest(userEmail: String, completion: @escaping (_ isSuccess: Bool, _ verificationNeeded: Bool) -> Void) {
        Alamofire.request(URL(string: ServerConfig.acctForgetPwSendEmailURL)!,
                          method: .post,
                          parameters: ["email": userEmail],
                          encoding: JSONEncoding.default,
                          headers: [:])
        .validate()
            .responseJSON {(response) -> Void in
            guard response.result.isSuccess else {
                print ("Failed to request verification email")
                completion (false, false)
                return
            }
            let jsonObj = JSON(response.result.value)
            if let data = jsonObj["data"].dictionaryObject {
                if let needVerify = data["verification"] {
                    completion (true, needVerify as! Bool)
                    return
                }
            }
            completion(true, false)
        }
    }

    public func resetVerifyRequest(userEmail: String, verificationCode: String, completion: @escaping (_ isSuccess: Bool) -> Void) {
        Alamofire.request(URL(string: ServerConfig.acctForgetPwEmailVerifURL)!,
                          method: .post,
                          parameters: ["email": userEmail, "code": verificationCode],
                          encoding: JSONEncoding.default,
                          headers: [:])
            .validate()
            .responseJSON {(response) -> Void in
                guard response.result.isSuccess else {
                    print ("Failed to request verification email")
                    completion (false)
                    return
                }
                let jsonObj = JSON(response.result.value)
                if jsonObj["message"] == "Verification success"{
                    completion(true)
                } else {
                    completion(false)
                }
        }
    }

    public func resetChangePwRequest(userEmail: String, password: String, completion: @escaping (_ isSuccess: Bool) -> Void) {
        Alamofire.request(URL(string: ServerConfig.acctForgetPwResetURL)!,
                          method: .post,
                          parameters: ["email": userEmail, "password": password],
                          encoding: JSONEncoding.default,
                          headers: [:])
            .validate()
            .responseJSON {(response) -> Void in
                guard response.result.isSuccess else {
                    print ("Failed to request verification email")
                    completion (false)
                    return
                }
                let jsonObj = JSON(response.result.value)
                if let data = jsonObj["data"].dictionaryObject {
                    if let success = data["email_sending_result"] {
                        if jsonObj["data"]["email_sending_result"] == "success"{
                            completion(true)
                            return
                        }
                    }
                }
                completion(false)
        }
    }

    public func loginRequest(userEmail: String, password: String, completion: @escaping (_ isSuccess: Bool) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.userLoginURL)!,
            method: .post,
            parameters: ["email": userEmail, "password": password],
            encoding: JSONEncoding.default,
            headers: [:])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("Login Failed due to :")
                    completion(false)
                    return
                }
                let jsonObj = JSON(response.result.value)
                if jsonObj["message"] == "Login success"{
                    //save uuid & nickname, TODO change to save user object
                    let preferences = UserDefaults.standard
                    let nicknameKey = "nickname"
                    let userNameKey = "username"
                    let userIdKey = "userId"
                    preferences.setValue(jsonObj["data"]["id"].stringValue, forKey: userIdKey)
                    preferences.setValue(jsonObj["data"]["email"].stringValue, forKey: userNameKey)
                    preferences.setValue(jsonObj["data"]["name"].stringValue, forKey: nicknameKey)
                    completion(true)
                } else {
                    completion(false)
                }
        }
    }

    public func thirdPartyLoginRequest(appUserId: String, nickName: String, platform: String, completion: @escaping (_ isSuccess: Bool) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.thirdPartyLoginURL)!,
            method: .post,
            parameters: ["id": appUserId, "nickname": nickName, "platform": platform],
            encoding: JSONEncoding.default,
            headers: [:])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("Login Failed due to : \(String(describing: response.result.error))")
                    completion(false)
                    return
                }
                guard let value = response.result.value as? JSON else {
                    print("Login Failed due to : Server Data Type Error")
                    completion(false)
                    return
                }
                let userId = value["id"].stringValue
                let nickname = value["nickname"].stringValue
                //                let rooms = rows.flatMap({ (roomDict) -> RemoteRoom? in
                //                    return RemoteRoom(jsonData: roomDict)
                //                })
                completion(true)
        }
    }

    public func register(uuid: String, nickName: String, email: String, password: String, completion: @escaping (_ isSuccess: Bool) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.registry)!,
            method: .post,
            parameters: ["id": uuid, "name": nickName, "email": email, "password": password],
            encoding: JSONEncoding.default,
            headers: [:])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    completion(false)
                    return
                }
                let jsonObj = JSON(response.result.value)
                if jsonObj["message"] == "Register success"{
                    let preferences = UserDefaults.standard
                    let nicknameKey = "nickname"
                    let userNameKey = "username"
                    let userIdKey = "userId"
                    preferences.setValue(jsonObj["data"]["id"].stringValue, forKey: userIdKey)
                    preferences.setValue(jsonObj["data"]["email"].stringValue, forKey: userNameKey)
                    preferences.setValue(jsonObj["data"]["name"].stringValue, forKey: nicknameKey)
                    completion(true)
                } else {
                     completion(false)
                }

        }
    }

    public func getArticleList(completion: @escaping ([Article]?) -> Void) {
            Alamofire.request(
                URL(string: ServerConfig.articleURL)!,
                method: .get)
                .validate()
                .responseJSON { (response) -> Void in
                    guard response.result.isSuccess else {
                        print("Get articles failed due to : \(String(describing: response.result.error))")
                        completion(nil)
                        return
                    }
                    guard let articles = response.result.value else {
                        print("Get articles failed due to : Server Data Type Error")
                        completion(nil)
                        return
                    }
                    let jsonArr = JSON(articles)
                    let articleList: [Article] = ArticleDataManager.instance.assembleArticles(jsonArr: jsonArr)
                    completion(articleList)
        }
    }

    public func getEventList(completion: @escaping ([Article]?) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.eventURL)!,
            method: .get)
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("Get articles failed due to : \(String(describing: response.result.error))")
                    completion(nil)
                    return
                }
                guard let articles = response.result.value else {
                    print("Get articles failed due to : Server Data Type Error")
                    completion(nil)
                    return
                }
                let jsonArr = JSON(articles)
                let articleList: [Article] = ArticleDataManager.instance.assembleEvents(jsonArr: jsonArr)
                completion(articleList)
        }
    }

    public func getFoodSearchResult(keywords: String, completion: @escaping ([TextSearchSuggestionEntity]?) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.foodSearchListURL)!,
            method: .post,
            parameters: ["text": keywords],
            encoding: JSONEncoding.default,
            headers: [:])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("Get search result failed due to : \(String(describing: response.result.error))")
                    completion(nil)
                    return
                }

                guard let searchResults = response.result.value else {
                    print("Get searchResult failed due to : Server Data Type Error")
                    completion(nil)
                    return
                }
                let jsonArr = JSON(searchResults)["data"]
                var foodSearchList = [TextSearchSuggestionEntity]()
                for i in 0..<jsonArr.count {
                    let entity = TextSearchSuggestionEntity(id: (jsonArr[i].dictionaryValue["id"]?.intValue)!, name: (jsonArr[i].dictionaryValue["name"]?.stringValue)!)
                    foodSearchList.append(entity)
                }
                completion(foodSearchList)
        }
    }

    public func getIngredientSearchResult(keywords: String, completion: @escaping ([TextSearchSuggestionEntity]?) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.ingredientSearchURL)!,
            method: .post,
            parameters: ["text": keywords],
            encoding: JSONEncoding.default,
            headers: [:])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("Get ingredient search result failed due to : \(String(describing: response.result.error))")
                    completion(nil)
                    return
                }

                guard let searchResults = response.result.value else {
                    print("Get  ingredient searchResult failed due to : Server Data Type Error")
                    completion(nil)
                    return
                }
                let jsonArr = JSON(searchResults)["data"]
                var foodSearchList = [TextSearchSuggestionEntity]()
                for i in 0..<jsonArr.count {
                    let entity = TextSearchSuggestionEntity(id: (jsonArr[i].dictionaryValue["id"]?.intValue)!, name: (jsonArr[i].dictionaryValue["name"]?.stringValue)!)
                    foodSearchList.append(entity)
                }
                completion(foodSearchList)
        }
    }

    public func getFoodSearchDetailResult(foodId: Int, completion: @escaping (FoodInfomation?) -> Void) {
        let url = ServerConfig.foodSearchListURL+"?id="+String(foodId)
        Alamofire.request(
            URL(string: url)!,
            method: .get,
            parameters: ["id": foodId],
            encoding: JSONEncoding.default,
            headers: [:])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                print("Get food detail failed due to : \(String(describing: response.result.error))")
                completion(nil)
                    return
                }
                guard let detail = response.result.value else {
                    print("Get food detail failed due to : Server Data Type Error")
                    completion(nil)
                    return
                }
                let jsonObj = JSON(detail)["data"]
                let foodInfo = FoodInfoDataManager.instance.assembleTextFoodInfo(jsonObject: jsonObj)
                completion(foodInfo)
        }
    }

    public func getIngredientSearchDetailResult(foodId: Int, completion: @escaping (Ingredient?) -> Void) {
        let url = ServerConfig.ingredientSearchURL+"?id="+String(foodId)
        Alamofire.request(
            URL(string: url)!,
            method: .get,
            parameters: ["id": foodId],
            encoding: JSONEncoding.default,
            headers: [:])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("Get food detail failed due to : \(String(describing: response.result.error))")
                    completion(nil)
                    return
                }
                guard let detail = response.result.value else {
                    print("Get food detail failed due to : Server Data Type Error")
                    completion(nil)
                    return
                }
                let jsonObj = JSON(detail)["data"]
                let ingredient = FoodInfoDataManager.instance.assembleIngredientInfo(jsonObject: jsonObj)
                completion(ingredient)
        }
    }

    public func getBarcodeScanResult(barcode: String, completion: @escaping (FoodInfomation?) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.barcodeSearchURL+"?id="+barcode)!,
            method: .get,
            encoding: JSONEncoding.default,
            headers: [:])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("Get search result failed due to : \(String(describing: response.result.error))")
                    completion(nil)
                    return
                }
                guard let scanResult = response.result.value else {
                    print("Get searchResult failed due to : Server Data Type Error")
                    completion(nil)
                    return
                }
                let jsonObject = JSON(scanResult)["data"]
                if jsonObject == nil {
                    completion(nil)
                } else {
                    let barcodeScanResult = FoodInfoDataManager.instance.assembleBarcodeFoodInfo(jsonObject: jsonObject)
                    completion(barcodeScanResult)
                }
        }
    }

    public func uploadRecognitionImage(imgData: Data, userId: String, latitude: Double, longitude: Double, completion: @escaping ([FoodInfomation]?) -> Void) {
        let parameters = ["user_id": userId]
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imgData, withName: "image_file", fileName: "temp.png", mimeType: "image/png")
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        }, to: ServerConfig.imageUploadURL) {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (progress) in
                    #if DEBUG
                    print("Upload Progress: \(progress.fractionCompleted)")
                    #endif
                })
                upload.responseJSON { response in
                    let resultObj = JSON(response.value)
                    let resultList = FoodInfoDataManager.instance.assembleFoodInfos(jsonObj: resultObj)
                    completion(resultList)
//                    print(response.result.value)
                }
            case .failure(let encodingError):
                print(encodingError)
                completion(nil)
            }
        }
    }

    public func saveDeviceToken(uuid: String, fcmToken: String, status: String, completion: @escaping (Bool) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.userURL+"/\(uuid)/device/")!,
            method: .put,
            parameters: ["token": fcmToken, "status": status, "device_type": "ios"],
            encoding: JSONEncoding.default,
            headers: [:])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("save device token failed due to : \(String(describing: response.result.error))")
                    completion(false)
                    return
                }
                guard let scanResult = response.result.value else {
                    print("save device token failed due to : Server Data Type Error")
                    completion(false)
                    return
                }
                let jsonObject = JSON(scanResult)
                if jsonObject == nil {
                    completion(false)
                } else {
                    completion(true)
                }
        }
    }

    public func sendFeedBack(userId: String, content: String, completion: @escaping (Bool) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.feedBackURL+"?user_id="+userId)!,
            method: .post,
            parameters: ["text": content],
            encoding: JSONEncoding.default,
            headers: [:])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("save device token failed due to : \(String(describing: response.result.error))")
                    completion(false)
                    return
                }
                guard let scanResult = response.result.value else {
                    print("save device token failed due to : Server Data Type Error")
                    completion(false)
                    return
                }
                let jsonObject = JSON(scanResult)["message"]
                if jsonObject == nil {
                    completion(false)
                } else {
                    completion(true)
                }
        }
    }

    public func getProfile(userId: String, completion: @escaping (UserProfile?) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.userURL + "/" + userId + "/profile/")!,
            method: .get,
            encoding: JSONEncoding.default,
            headers: [:])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("get profile failed due to : \(String(describing: response.result.error))")
                    completion(nil)
                    return
                }
                guard let scanResult = response.result.value else {
                    print("get profile failed due to : Server Data Type Error")
                    completion(nil)
                    return
                }
                let jsonObject = JSON(scanResult)["data"]
                let userProfile = ProfileDataManager.instance.assembleUserProfile(jsonObj: jsonObject)
                if jsonObject == nil {
                    completion(nil)
                } else {
                    completion(userProfile)
                }
        }
    }

    public func updateProfile(userId: String, name: String, gender: Int, height: Double, weight: Double, completion: @escaping (Bool) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.userURL + "/" + userId + "/profile/")!,
            method: .put,
            parameters: ["name": name, "gender": gender, "height": height, "weight": weight],
            encoding: JSONEncoding.default,
            headers: [:])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("update profile failed due to : \(String(describing: response.result.error))")
                    completion(false)
                    return
                }
                guard let scanResult = response.result.value else {
                    print("update profile failed due to : Server Data Type Error")
                    completion(false)
                    return
                }
                let jsonObject = JSON(scanResult)["message"]
                if jsonObject == nil {
                    completion(false)
                } else {
                    completion(true)
                }
        }
    }

    public func getNotificationList(userId: String, completion: @escaping ([NotificationModel]?) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.NotificationURL + "/list/?user_id=" + userId)!,
            method: .get,
            encoding: JSONEncoding.default,
            headers: [:])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("get notifcation failed due to : \(String(describing: response.result.error))")
                    completion(nil)
                    return
                }
                guard let scanResult = response.result.value else {
                    print("get notifcation failed due to : Server Data Type Error")
                    completion(nil)
                    return
                }
                let jsonArr = JSON(scanResult)["data"]
                let notications = NotificationDataManager.instance.assembleUserNotification(jsonArr: jsonArr)
                if jsonArr == nil {
                    completion(nil)
                } else {
                    completion(notications)
                }
        }
    }

    public func didReceiveNotifcation(notificationId: String, completion: @escaping (Bool?) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.NotificationURL + "/" + notificationId + "/")!,
            method: .put,
            parameters: ["status": "read"],
            encoding: JSONEncoding.default,
            headers: [:])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("get notifcation failed due to : \(String(describing: response.result.error))")
                    completion(false)
                    return
                }
                guard let scanResult = response.result.value else {
                    print("get notifcation failed due to : Server Data Type Error")
                    completion(false)
                    return
                }
                let jsonObj = JSON(scanResult)
                if jsonObj == nil {
                    completion(false)
                } else {
                    completion(true)
                }
        }
    }

    public func deleteAllNotification(userId: String, completion: @escaping (Bool?) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.NotificationURL + "/all/"+"?user_id=" + userId)!,
            method: .delete,
            encoding: JSONEncoding.default,
            headers: [:])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.response?.statusCode == 204 else {
                    print("get notifcation failed due to : \(String(describing: response.result.error))")
                    completion(false)
                    return
                }
                guard let scanResult = response.result.value else {
                    print("get notifcation failed due to : Server Data Type Error")
                    completion(false)
                    return
                }
                completion(true)
        }
    }

    public func deleteNotification(notificationId: String, completion: @escaping (Bool?) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.NotificationURL + "/"+notificationId+"/")!,
            method: .delete,
            encoding: JSONEncoding.default,
            headers: [:])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.response?.statusCode == 204 else {
                    print("get notifcation failed due to : \(String(describing: response.result.error))")
                    completion(false)
                    return
                }
                guard let scanResult = response.result.value else {
                    print("get notifcation failed due to : Server Data Type Error")
                    completion(false)
                    return
                }
                completion(true)
        }
    }

    //swiftlint:disable function_parameter_count
    /// save FoodDiary API
    ///
    /// - Parameters:
    ///   - foodDiary: foodDiary
    ///   - imageUrl: food imageURl need to send to backend
    ///   - fileName: image local storage filename
    ///   - mealTime: dd MM yyyy foodDiary date
    ///   - mealType: breakfast|lunch|dinner|snacks
    ///   - recordType: Image|Text|Barcode|Customize
    ///   - category: food category
    ///   - ratio: portion ratio
    ///   - completion: for passing callback
    public func saveFoodDiary(userId: String, foodDiary: FoodDiary, mealTime: String, mealType: String, nutrientJson: String, ingredientJson: String, recordType: String, category: String, rank: Int, completion: @escaping (Bool) -> Void) {
        var params: Dictionary = ["food_name": foodDiary.foodName, "portion_size": foodDiary.portionSize, "meal_type": mealType, "nutrient": nutrientJson, "ingredient": ingredientJson, "search_type": recordType, "rank": String(rank)] as [String: Any]
        Alamofire.request(
            URL(string: ServerConfig.saveFoodDiaryURL+"?user_id="+userId)!,
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: [:])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("Save food diary failed due to : \(String(describing: response.result.error))")
                    completion(false)
                    return
                }
                guard let result = response.result.value else {
                    print("Save food diary failed due to : Server Data Type Error")
                    completion(false)
                    return
                }
                let jsonObject = JSON(result)
                completion(true)
        }
    }

    public func uploadStepData(userId: String, params: Dictionary<String, Any>, completion: @escaping (Bool) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.saveStepDiaryURL+"?user_id="+userId)!,
            method: .put,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: [:])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("Save exercise data failed due to : \(String(describing: response.result.error))")
                    completion(false)
                    return
                }
                guard let result = response.result.value else {
                    print("Save exercise data failed due to : Server Data Type Error")
                    completion(false)
                    return
                }
                let jsonObject = JSON(result)
                completion(true)
        }
    }

    //healthCenter
    func uploadHealthCenterData(userId: String, title: String, content: String, unit: String, amount: String, datetime: String, completion: @escaping (Bool) -> Void) {
        let params = ["title": title, "content": content, "unit": unit, "amount": amount, "datetime": datetime]
        Alamofire.request(
            URL(string: ServerConfig.saveHealthCenterDataURL+"?user_id="+userId)!,
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: [:])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("Save exercise data failed due to : \(String(describing: response.result.error))")
                    completion(false)
                    return
                }
                guard let result = response.result.value else {
                    print("Save exercise data failed due to : Server Data Type Error")
                    completion(false)
                    return
                }
                let jsonObject = JSON(result)
                completion(true)
        }
    }

    //cancel task
    func cancelRequest(requestURL: String) {
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach {
                if ($0.originalRequest?.url?.absoluteString == requestURL) {
                    $0.cancel()
                }
            }
            uploadData.forEach { $0.cancel() }
            downloadData.forEach { $0.cancel() }
        }
    }
    //basic authentication header
    func getBasicAuthenticationHeader() -> Dictionary<String, String> {
        let preferences = UserDefaults.standard
        let userNameKey = "username"
        let pwdKey = "password"
        let userName = preferences.string(forKey: userNameKey)
        let password = preferences.string(forKey: pwdKey)
        let credentialData = "\(userName):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString(options: [])
        let headers = ["Authorization": "Basic \(base64Credentials)"]
        return headers
    }

}
