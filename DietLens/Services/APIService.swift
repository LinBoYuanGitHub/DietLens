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
import QiniuUpload
import Kingfisher

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

    public func resetPwRequest(userEmail: String, completion: @escaping (_ isSuccess: Bool) -> Void) {
        Alamofire.request(URL(string: ServerConfig.forgetPwdUrl)!,
                          method: .post,
                          parameters: ["email": userEmail],
                          encoding: JSONEncoding.default,
                          headers: [:])
        .validate()
            .responseJSON {(response) -> Void in
            guard response.result.isSuccess else {
                print ("Failed to request verification email")
                completion (false)
                return
            }
            completion(true)
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
                completion(true)
        }
    }

    public func facebookIdValidationRequest(accessToken: String, uuid: String, completion:@escaping (_ isSuccess: Bool, _ isNewUser: Bool) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.facebookIdValidationURL)!,
            method: .post,
            parameters: ["access_token": accessToken, "uid": uuid],
            encoding: JSONEncoding.default,
            headers: [:])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("facebook uid validation failed")
                    completion(false, false)
                    if response.response?.statusCode == 401 {
                        //redirect to login page
                    }
                    return
                }
                guard (response.response?.allHeaderFields) != nil else {
                    print("Get Token failed")
                    return
                }
                //get token
                let preferences = UserDefaults.standard
                let token = response.response!.allHeaderFields["token"]
                preferences.setValue(token, forKey: PreferenceKey.tokenKey)
                //get userId
                let userId = JSON(response.result.value)["data"]["id"].stringValue
                preferences.setValue(userId, forKey: PreferenceKey.userIdkey)
                //get isNewUser flag
                let isNewUser = JSON(response.result.value)["data"]["is_new_user"].boolValue
                completion(true, isNewUser)
        }
    }

    public func emailValidationRequest(userEmail: String, completion:@escaping (_ isSuccess: Bool) -> Void, failedComoletion: @escaping (_ failedMsg: String) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.checkEmailURL)!,
            method: .post,
            parameters: ["email": userEmail],
            encoding: JSONEncoding.default,
            headers: [:])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("Email checking web API invoke failed")
                    completion(false)
                    return
                }
                let jsonObj = JSON(response.result.value)
                let status = jsonObj["status"].intValue
                if status == 1 {
                    completion(true)
                } else {
                    let errMsg = jsonObj["message"].stringValue
                    failedComoletion(errMsg)
                    completion(false)
                }
        }
    }

    public func loginRequest(userEmail: String, password: String, completion: @escaping (_ isSuccess: Bool) -> Void, failedCompletion: @escaping (_ errMsg: String) -> Void) {
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
                guard (response.response?.allHeaderFields) != nil else {
                    completion(false)
                    print("Get Token failed")
                    return
                }
                let jsonObj = JSON(response.result.value)
                let errMsg = jsonObj["error_message"].stringValue
                if jsonObj["error_message"].stringValue != "" {
                    failedCompletion(errMsg)
                    return
                }
                if jsonObj["message"] == "Login success" {
                    //save uuid & nickname, change to save user object
                    let preferences = UserDefaults.standard
                    let nicknameKey = "nickname"
                    let userNameKey = "username"
                    let userIdKey = "userId"
                    let token = response.response!.allHeaderFields["token"]
                    preferences.setValue(token, forKey: PreferenceKey.tokenKey)
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
//                let userId = value["id"].stringValue
//                let nickname = value["nickname"].stringValue
                //                let rooms = rows.flatMap({ (roomDict) -> RemoteRoom? in
                //                    return RemoteRoom(jsonData: roomDict)
                //                })
                completion(true)
        }
    }

    public func register(nickName: String, email: String, password: String, completion: @escaping (_ isSuccess: Bool) -> Void, failedCompletion: @escaping(_ failedMsg: String) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.registry)!,
            method: .post,
            parameters: ["name": nickName, "email": email, "password": password],
            encoding: JSONEncoding.default,
            headers: [:])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    completion(false)
                    return
                }
                let jsonObj = JSON(response.result.value)
                if jsonObj["error_message"] != JSON.null {
                    failedCompletion(jsonObj["error_message"].stringValue)
                    return
                }
                guard ((response.response?.allHeaderFields) != nil) else {
                    completion(false)
                    print("Get Token failed")
                    return
                }
                if jsonObj["message"].rawString() == "Register success"{
                    let preferences = UserDefaults.standard
                    let nicknameKey = "nickname"
                    let userNameKey = "username"
                    let userIdKey = "userId"
                    let token = response.response!.allHeaderFields["token"]
                    preferences.setValue(token, forKey: PreferenceKey.tokenKey)
                    preferences.setValue(jsonObj["data"]["id"].stringValue, forKey: userIdKey)
                    preferences.setValue(jsonObj["data"]["email"].stringValue, forKey: userNameKey)
                    preferences.setValue(jsonObj["data"]["name"].stringValue, forKey: nicknameKey)
                    completion(true)
                } else {
                    completion(false)
                }

        }
    }

    public func getArticleList(completion: @escaping ([Article]?) -> Void, nextLinkCompletion: @escaping (String) -> Void) {
            Alamofire.request(
                URL(string: ServerConfig.articleURL+"/?type=0")!,
                method: .get,
                headers: getTokenHeader())
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
                    let nextLink = JSON(articles)["next"].stringValue
                    let articleList: [Article] = ArticleDataManager.instance.assembleArticles(jsonArr: jsonArr)
                    nextLinkCompletion(nextLink)
                    completion(articleList)
        }
    }

    public func getArticleList(link: String, completion: @escaping ([Article]?) -> Void, nextLinkCompletion: @escaping (String) -> Void) {
        Alamofire.request(
            URL(string: link)!,
            method: .get,
            headers: getTokenHeader())
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
                let nextLink = JSON(articles)["next"].stringValue
                let articleList: [Article] = ArticleDataManager.instance.assembleArticles(jsonArr: jsonArr)
                nextLinkCompletion(nextLink)
                completion(articleList)
        }
    }

    public func getEventList(completion: @escaping ([Article]?) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.articleURL+"/?type=1")!,
            method: .get,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("Get events failed due to : \(String(describing: response.result.error))")
                    completion(nil)
                    return
                }
                guard let articles = response.result.value else {
                    print("Get events failed due to : Server Data Type Error")
                    completion(nil)
                    return
                }
                let jsonArr = JSON(articles)
                let articleList: [Article] = ArticleDataManager.instance.assembleEvents(jsonArr: jsonArr)
                completion(articleList)
        }
    }

    public func autoCompleteText(keywords: String, completion: @escaping ([String]?) -> Void ) {
        Alamofire.request(
            URL(string: ServerConfig.foodSearchAutocompleteURL)!,
            method: .post,
            parameters: ["text": keywords],
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("get autoComplete result failed due to : \(String(describing: response.result.error))")
                    completion(nil)
                    return
                }

                guard let searchResults = response.result.value else {
                    print("get autoComplete result failed due to : Server Data Type Error")
                    completion(nil)
                    return
                }
                let jsonArr = JSON(searchResults)["data"]
                var resultList = [String]()
                for index in 0..<jsonArr.count {
                    let result = jsonArr[index].dictionaryValue["name"]?.stringValue
                    resultList.append(result!)
                }
                completion(resultList)
        }
    }

    public func getFoodSearchResult(requestUrl: String, keywords: String, latitude: Double, longitude: Double, completion: @escaping ([TextSearchSuggestionEntity]?) -> Void, nextPageCompletion: @escaping (String?) -> Void) {
        Alamofire.request(
            URL(string: requestUrl)!,
            method: .post,
            parameters: ["food_name": keywords, "lat": latitude, "long": longitude],
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("Get search result failed due to : \(String(describing: response.result.error))")
                    if response.response?.statusCode == 401 {
                        NotificationCenter.default.post(name: .signOutErrFlag, object: nil)
                    }
                    completion(nil)
                    return
                }
                guard let searchResults = response.result.value else {
                    print("Get searchResult failed due to : Server Data Type Error")
                    completion(nil)
                    return
                }
                let jsonObj = JSON(searchResults)
                let jsonArr = jsonObj["data"]
                let nextLink = jsonObj["next"].stringValue
                var foodSearchList = [TextSearchSuggestionEntity]()
                for index in 0..<jsonArr.count {
                    let dict = jsonArr[index].dictionaryValue
                    var entity = TextSearchSuggestionEntity(id: (dict["id"]?.intValue)!, name: (dict["name"]?.stringValue)!, useExpImage: (dict["is_exp_img"]?.bool)!, expImagePath: (dict["example_img"]?.stringValue)! )
                    entity.location = dict["location"]!.stringValue
                    entity.stall = dict["stall"]!.stringValue
                    foodSearchList.append(entity)
                }
                nextPageCompletion(nextLink)
                completion(foodSearchList)
        }
    }

    public func getFoodSearchResult(filterType: Int, keywords: String, latitude: Double, longitude: Double, completion: @escaping ([TextSearchSuggestionEntity]?) -> Void, nextPageCompletion: @escaping (String?) -> Void) {
        let url = ServerConfig.foodFullTextSearchURL + "?category=" + String(filterType)
        self.getFoodSearchResult(requestUrl: url, keywords: keywords, latitude: latitude, longitude: longitude, completion: completion, nextPageCompletion: nextPageCompletion)
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
                for index in 0..<jsonArr.count {
                    let entity = TextSearchSuggestionEntity(id: (jsonArr[index].dictionaryValue["id"]?.intValue)!, name: (jsonArr[index].dictionaryValue["name"]?.stringValue)!, useExpImage: false, expImagePath: "")
                    foodSearchList.append(entity)
                }
                completion(foodSearchList)
        }
    }

    public func getFoodSearchDetailResult(foodId: Int, completion: @escaping (FoodInfomationModel?) -> Void) {
        let url = ServerConfig.foodSearchListURL+"?id="+String(foodId)
        Alamofire.request(
            URL(string: url)!,
            method: .get,
            parameters: ["id": foodId],
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
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

    public func getBarcodeScanResult(barcode: String, completion: @escaping (FoodInfomationModel?) -> Void) {
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

    /**
     * use qinniu server as to store the image
     * param: imageData
     * return: imageKey
    */
    public func qiniuImageUpload(imgData: Data, completion: @escaping (String?) -> Void, progressCompletion: @escaping (Int) -> Void) {
//        let uploadUrl = "http://upload.qiniu.com/"
        QiniuToken.register(withScope: QiniuConfig.scope, secretKey: QiniuConfig.secretKey, accesskey: QiniuConfig.accessKey)
        if let uploadToken = QiniuToken.shared().uploadToken() {
//            let file = QiniuFile(imgData as NSData)
            let uploader = QiniuUploader()
            let file = QiniuFile(fileData: imgData)
            uploader.files.append(file)
            uploader.startUpload(uploadToken, uploadOneFileSucceededHandler: { (index, keyValuePair) in
                print("upload succeeded : \(index) - \(keyValuePair)")
                if let key = keyValuePair["key"] as? String {
//                    let url = "\(QiniuConfig.rootDomain)/\(QiniuConfig.accessKey)&token=\(key)"
//                    print(url)
                    completion(key)
                }
            }, uploadOneFileFailedHandler: { (index, error) in
                print("upload Failed : \(index) - \(error)")
                print("upload failed")
                completion(nil)
            }, uploadOneFileProgressHandler: { (_, _, totalBytesSent, totalBytesExpectedToSend) in
                let progress = Int(totalBytesSent/totalBytesExpectedToSend * 100)
                progressCompletion(progress)
            }, uploadAllFilesComplete: {
                print("upload complete...")
            })
        }
    }

    //http://<domain>/<key>?e=<deadline>&token=<downloadToken>
    public func qiniuImageDownload(imageKey: String, width: Int, height: Int, completion: @escaping (UIImage?) -> Void) {
        let downloadURL = "https://img.dietlens.com/"+imageKey+"?imageView2/5/w/"+String(width)+"/h/"+String(height)
        let downloadImageView = UIImageView()
        let url = URL(string: downloadURL)!
        downloadImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "loading_img"), options: [], progressBlock: nil) { (image, _, _, _) in
            completion(image)
        }
    }

    public func qiniuImageDownload(imageKey: String, completion: @escaping (UIImage?) -> Void) {
        let downloadURL = "https://img.dietlens.com/"+imageKey
        let downloadImageView = UIImageView()
        let url = URL(string: downloadURL)!
        downloadImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "loading_img"), options: [], progressBlock: nil) { (image, _, _, _) in
            completion(image)
        }
    }

    /**
     * get image recognition result
     * param: imageKey,latitude,longitude
     * return: List of DisplayFoodCategory
     */
    public func postForRecognitionResult(imageKey: String, latitude: Double, longitude: Double, completion: @escaping ([DisplayFoodCategory]?) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.uploadImageKeyURL)!,
            method: .post,
            parameters: ["key": imageKey, "latitude": latitude, "longitude": longitude],
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("Get recognition result failed due to : \(String(describing: response.result.error))")
                    completion(nil)
                    return
                }
                guard let recogResult = response.result.value else {
                    print("Get recognition failed due to : Server Data Type Error")
                    completion(nil)
                    return
                }
                let jsonObject = JSON(recogResult)["data"]
                let displayCategory = FoodInfoDataManager.instance.assembleDisplayFoodCategoryData(data: jsonObject)
                if jsonObject == JSON.null {
                    //not json data, return null
                    completion(nil)
                } else {
                   //assemble FoodInfo to return recognition result
                    completion(displayCategory)
                }
        }
    }

    //get food detail infomation(nutrition & portion)
    public func getFoodDetail(foodId: Int, completion: @escaping (DietItem?) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.foodDiaryOperationURL+String(foodId)+"/")!,
            method: .get,
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    if response.response?.statusCode == 401 {
                        NotificationCenter.default.post(name: .signOutErrFlag, object: nil)
                    }
                    print("get food detail failed due to : \(String(describing: response.result.error))")
                    completion(nil)
                    return
                }
                guard let scanResult = response.result.value else {
                    print("get food detail failed due to : Server Data Type Error")
                    completion(nil)
                    return
                }
                let jsonObject = JSON(scanResult)
                if jsonObject.count == 0 {
                    completion(nil)
                } else {
                    let dietItem = FoodInfoDataManager.instance.assembleDietItem(jsonObject: jsonObject)
                    completion(dietItem)
                }
        }
    }

    //delete single foodItem inside foodDiary
    public func deleteFoodItem(foodDiaryId: String, foodItemId: String, completion: @escaping(Bool) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.foodDiaryDietItems)!,
            method: .post,
            parameters: ["dietlog_id": foodDiaryId, "item": foodItemId],
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    if response.response?.statusCode == 401 {
                        NotificationCenter.default.post(name: .signOutErrFlag, object: nil)
                    }
                    print("delete single foodItem failed due to : \(String(describing: response.result.error))")
                    completion(false)
                    return
                }
                guard let scanResult = response.result.value else {
                    print("delete single foodItem failed due to : Server Data Type Error")
                    completion(false)
                    return
                }
                completion(true)
        }
    }

    //delete whole foodDiary
    public func deleteFoodDiary(foodDiaryId: String, completion:@escaping(Bool) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.foodDiaryDietLogs+foodDiaryId+"/")!,
            method: .delete,
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    if response.response?.statusCode == 401 {
                        NotificationCenter.default.post(name: .signOutErrFlag, object: nil)
                    }
                    print("delete foodDiary failed due to : \(String(describing: response.result.error))")
                    completion(false)
                    return
                }
                guard let scanResult = response.result.value else {
                    print("delete foodDiary failed due to : Server Data Type Error")
                    completion(false)
                    return
                }
                completion(true)
        }
    }

    public func deleteFoodDiaryList(foodDiaryIds: [String], completion:@escaping(Bool) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.foodDiaryDeleteAll)!,
            method: .post,
            parameters: ["discarded_logs": foodDiaryIds],
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    if response.response?.statusCode == 401 {
                        NotificationCenter.default.post(name: .signOutErrFlag, object: nil)
                    }
                    print("delete foodDiary failed due to : \(String(describing: response.result.error))")
                    completion(false)
                    return
                }
                guard let scanResult = response.result.value else {
                    print("delete foodDiary failed due to : Server Data Type Error")
                    completion(false)
                    return
                }
                completion(true)
        }
    }

    //update foodDiary
    public func updateFoodDiary(isPartialUpdate: Bool, foodDiary: FoodDiaryEntity, completion:@escaping(Bool) -> Void) {
        var param: [String: Any] = [:]
        if isPartialUpdate {
            param = FoodInfoDataManager.instance.partialParamfyFoodDiaryEntity(foodDiaryEntity: foodDiary)
        } else {
            param = FoodInfoDataManager.instance.paramfyFoodDiaryEntity(foodDiaryEntity: foodDiary)
        }
        Alamofire.request(
            URL(string: ServerConfig.foodDiaryDietLogs+foodDiary.foodDiaryId+"/")!,
            method: .put,
            parameters: param,
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    if response.response?.statusCode == 401 {
                        NotificationCenter.default.post(name: .signOutErrFlag, object: nil)
                    }
                    print("update foodDiary failed due to : \(String(describing: response.result.error))")
                    completion(false)
                    return
                }
                guard let scanResult = response.result.value else {
                    print("update foodDiary failed due to : Server Data Type Error")
                    completion(false)
                    return
                }
                completion(true)
        }
    }
    //create a new foodDiary -> save FoodItem & success
    public func createFooDiary(foodDiary: FoodDiaryEntity, completion:@escaping(Bool) -> Void) {
        let param = FoodInfoDataManager.instance.paramfyFoodDiaryEntity(foodDiaryEntity: foodDiary)
        Alamofire.request(
            URL(string: ServerConfig.foodDiaryDietLogs)!,
            method: .post,
            parameters: param,
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    if response.response?.statusCode == 401 {
                        NotificationCenter.default.post(name: .signOutErrFlag, object: nil)
                    }
                    print("create foodDiary failed due to : \(String(describing: response.result.error))")
                    completion(false)
                    return
                }
                guard let scanResult = response.result.value else {
                    print("create foodDiary failed due to : Server Data Type Error")
                    completion(false)
                    return
                }
                completion(true)
        }
    }

    //get daily foodDiary
    public func getFoodDiaryByDate(selectedDate: String, completion:@escaping([FoodDiaryEntity]?) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.foodDiaryDietLogs+"?meal_time="+selectedDate)!,
            method: .get,
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    if response.response?.statusCode == 401 {
                        NotificationCenter.default.post(name: .signOutErrFlag, object: nil)
                    }
                    print("get daily foodDiary failed due to : \(String(describing: response.result.error))")
                    completion(nil)
                    return
                }
                guard let result = response.result.value else {
                    print("get daily foodDiary failed due to : Server Data Type Error")
                    completion(nil)
                    return
                }
                let jsonObject = JSON(result)["results"]
                let foodDiaryList = FoodDiaryDataManager.instance.assembleFoodDiaryEntities(jsonObject: jsonObject)
                if foodDiaryList.count == 0 {
                    completion(nil)
                } else {
                    completion(foodDiaryList)
                }
        }
    }

    //get available date in month which log foodDiary
    public func getAvailableDate(year: String, month: String, completion:@escaping([Date]?) -> Void) {
        var dateArray = [Date]()
        let yearParam = Int(year) ?? 2018 //use 2018 as default year
        let monthParam = Int(month) ?? 1 //use 1 as default month
        Alamofire.request(
            URL(string: ServerConfig.foodDiaryCalendar)!,
            method: .post,
            parameters: ["year": yearParam, "month": monthParam],
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    if response.response?.statusCode == 401 {
                        NotificationCenter.default.post(name: .signOutErrFlag, object: nil)
                    }
                    print("get monthly available date failed due to : \(String(describing: response.result.error))")
                    completion(nil)
                    return
                }
                guard let result = response.result.value else {
                    print("get monthly available date failed due to : Server Data Type Error")
                    completion(nil)
                    return
                }
                let jsonObject = JSON(result)
                let dateObject = jsonObject["data"]["date"]
                 for index in 0..<dateObject.count {
                    //convert date string to date
                    let dateStr = dateObject[index].stringValue
                    let date = DateUtil.normalStringToDate(dateStr: dateStr)
                    dateArray.append(date)
                }
                if dateArray.count == 0 {
                    completion(nil)
                } else {
                    completion(dateArray)
                }
        }
    }

    /**
     * upload image to private server
     * param: imageData, userId, latitude, longitude
     * return: foodCategory,progressCompeletion
     */
    public func uploadImageForMatrix(imgData: Data, userId: String, latitude: Double, longitude: Double, completion: @escaping ( [DisplayFoodCategory]?) -> Void, progressCompletion: @escaping (Int) -> Void) {
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imgData, withName: "image_file", fileName: "temp.png", mimeType: "image/png")
        }, to: ServerConfig.uploadRecognitionURL) {
            (result) in
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (progress) in
                    #if DEBUG
                        print("Upload Progress: \(progress.fractionCompleted)")
                        progressCompletion(Int(progress.fractionCompleted*100))
                    #endif
                })
                upload.responseJSON { response in
                    let resultObj = JSON(response.value)
                    let resultList = MockedUpFoodData.instance.assembleFoodInfoData(data: resultObj["data"])
//                    let resultList = FoodInfoDataManager.instance.assembleFoodInfos(jsonObj: resultObj)
//                    let imageId = resultObj["data"]["id"].intValue
                    completion(resultList)
                }
            case .failure(let encodingError):
                print(encodingError)
                completion(nil)
            }
        }
    }

    /**
     * upload image to private server
     * param: imageData, userId, latitude, longitude
     * return: foodCategory,progressCompeletion
     */
    public func uploadRecognitionImage(imgData: Data, userId: String, latitude: Double, longitude: Double, completion: @escaping (Int, [FoodInfomationModel]?) -> Void, progressCompletion: @escaping (Int) -> Void) {
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
                    progressCompletion(Int(progress.fractionCompleted*100))
                    #endif
                })
                upload.responseJSON { response in
                    let resultObj = JSON(response.value)
                    let resultList = FoodInfoDataManager.instance.assembleFoodInfos(jsonObj: resultObj)
                    let imageId = resultObj["data"]["id"].intValue
                    completion(imageId, resultList)
//                    print(response.result.value)
                }
            case .failure(let encodingError):
                print(encodingError)
                completion(0, nil)
            }
        }
    }

    /**
     * upload fcmToken to server for push notification
     * param: uuid,status,fcmToken
     * return: is save success
     */
    public func saveDeviceToken(uuid: String, fcmToken: String, status: Bool, completion: @escaping (Bool) -> Void) {
        //consider the case that user haven't got the token
        //device type 1: IOS, 2: Android
        Alamofire.request(
            URL(string: ServerConfig.saveNotificationTokenURL)!,
            method: .put,
            parameters: ["token": fcmToken, "is_active": status, "device_type": "1"],
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    if response.response?.statusCode == 401 {
                        NotificationCenter.default.post(name: .signOutErrFlag, object: nil)
                    }
                    print("save device token failed due to : \(String(describing: response.result.error))")
                    completion(false)
                    return
                }
                completion(true)
            }
    }

    public func logOut(completion: @escaping (Bool) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.logOutURL)!,
            method: .post,
            parameters: [:],
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
//                    if response.response?.statusCode == 401 {
//                        NotificationCenter.default.post(name: .signOutErrFlag, object: nil)
//                    }
                    print("lgout failed due to : \(String(describing: response.result.error))")
                    completion(false)
                    return
                }
                guard let scanResult = response.result.value else {
                    print("lgout failed due to : Server Data Type Error")
                    completion(false)
                    return
                }
                let jsonObject = JSON(scanResult)
                if jsonObject["status"] == "HTTP_200_OK" {
                    completion(true)
                } else {
                    completion(false)
                }
        }
    }

    /**
     * send pure text information to backend
     * param: userId, content
     * return: isSuccess:Bool
     */
    public func sendFeedBack(content: String, completion: @escaping (Bool) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.feedBackURL)!,
            method: .post,
            parameters: ["content": content],
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    if response.response?.statusCode == 401 {
                        NotificationCenter.default.post(name: .signOutErrFlag, object: nil)
                    }
                    print("send feedback failed due to : \(String(describing: response.result.error))")
                    completion(false)
                    return
                }
                guard let scanResult = response.result.value else {
                    print("send feedback failed due to : Server Data Type Error")
                    completion(false)
                    return
                }
                completion(true)
        }
    }

    /**
     * get current user profile
     * param: userId
     * return: userProfile
     */
    public func getProfile(userId: String, completion: @escaping (UserProfile?) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.userURL + "/" + userId + "/")!,
            method: .get,
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
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
                let jsonObject = JSON(scanResult)
                let userProfile = ProfileDataManager.instance.assembleUserProfile(jsonObj: jsonObject)
                if jsonObject == nil {
                    completion(nil)
                } else {
                    completion(userProfile)
                }
        }
    }

    public func updateProfile(userId: String, profile: UserProfile, completion: @escaping (Bool) -> Void) {
        var genderText = ""
        if profile.gender == 0 {
            genderText = "2"
        } else if profile.gender == 1 {
            genderText = "1"
        } else {
            genderText = "0"
        }
        Alamofire.request(
            URL(string: ServerConfig.userURL + "/" + userId + "/")!,
            method: .put,
            parameters: ["name": profile.name, "activity_level": String(profile.activityLevel), "gender": genderText, "height": profile.height, "weight": profile.weight, "birthday": profile.birthday],
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    if response.response?.statusCode == 401 {
                        NotificationCenter.default.post(name: .signOutErrFlag, object: nil)
                    }
                    print("update profile failed due to : \(String(describing: response.result.error))")
                    completion(false)
                    return
                }
                //save profile into sharedPreference
                let preferences = UserDefaults.standard
                let nicknameKey = "nickname"
                preferences.set(profile.name, forKey: nicknameKey)
                completion(true)
        }
    }

    /**
     * update profile
     * param: all user profile information
     * return: isSuccess
     */
    public func updateProfile(userId: String, name: String, gender: Int, height: Double, weight: Double, birthday: String, completion: @escaping (Bool) -> Void) {
        //get user id
        let preferences = UserDefaults.standard
        let key = "userId"
        let userId = preferences.string(forKey: key)
        //gender
        var genderText = ""
        if gender == 0 {
            genderText = "2"
        } else if gender == 1 {
            genderText = "1"
        } else {
            genderText = "0"
        }
        Alamofire.request(
            URL(string: ServerConfig.userURL + "/" + userId! + "/")!,
            method: .put,
            parameters: ["name": name, "gender": genderText, "height": height, "weight": weight, "birthday": birthday],
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    if response.response?.statusCode == 401 {
                        NotificationCenter.default.post(name: .signOutErrFlag, object: nil)
                    }
                    print("update profile failed due to : \(String(describing: response.result.error))")
                    completion(false)
                    return
                }
                //save profile into sharedPreference
                let preferences = UserDefaults.standard
                let nicknameKey = "nickname"
                preferences.set(name, forKey: nicknameKey)
                completion(true)
        }
    }

    /**
     * get all the notification in list format
     * param: userId
     * return: list of notification
     */
    public func getNotificationList(completion: @escaping ([NotificationModel]?) -> Void, nextLinkCompletion: @escaping (String) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.notificationURL)!,
            method: .get,
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    if response.response?.statusCode == 401 {
                        NotificationCenter.default.post(name: .signOutErrFlag, object: nil)
                    }
                    print("get notifcation failed due to : \(String(describing: response.result.error))")
                    completion(nil)
                    return
                }
                guard let scanResult = response.result.value else {
                    print("get notifcation failed due to : Server Data Type Error")
                    completion(nil)
                    return
                }
                let jsonArr = JSON(scanResult)["results"]
                let nextLink = JSON(scanResult)["next"].stringValue
                //use notifications
                let notications = NotificationDataManager.instance.assembleUserNotification(jsonArr: jsonArr)
                nextLinkCompletion(nextLink)
                completion(notications)
        }
    }

    public func getNotificationList(link: String, completion: @escaping ([NotificationModel]?) -> Void, nextCompletion: @escaping (String?) -> Void) {
        Alamofire.request(
            link,
            method: .get,
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    if response.response?.statusCode == 401 {
                        NotificationCenter.default.post(name: .signOutErrFlag, object: nil)
                    }
                    print("get notifcation failed due to : \(String(describing: response.result.error))")
                    completion(nil)
                    return
                }
                guard let scanResult = response.result.value else {
                    print("get notifcation failed due to : Server Data Type Error")
                    completion(nil)
                    return
                }
                let jsonArr = JSON(scanResult)["results"]
                let nextLink = JSON(scanResult)["next"].stringValue
                let notications = NotificationDataManager.instance.assembleUserNotification(jsonArr: jsonArr)
                completion(notications)
                if nextLink != nil {
                     nextCompletion(nextLink)
                }
        }
    }

    public func getSingleNotification(notificationId: String, completion: @escaping (NotificationModel?) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.notificationURL+notificationId+"/")!,
            method: .get,
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    if response.response?.statusCode == 401 {
                        NotificationCenter.default.post(name: .signOutErrFlag, object: nil)
                    }
                    print("get notifcation failed due to : \(String(describing: response.result.error))")
                    completion(nil)
                    return
                }
                guard let result = response.result.value else {
                    print("get notifcation failed due to : Server Data Type Error")
                    completion(nil)
                    return
                }
                let jsonObj = JSON(result)
                let notication = NotificationDataManager.instance.assembleSingleUserNotification(jsonobj: jsonObj)
                completion(notication)
        }
    }

    /**
     * notify backend to mark notification has been received
     * param: userId
     * return: list of notification
     */
    public func didReceiveNotifcation(notificationId: String, completion: @escaping (Bool?) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.notificationURL + notificationId + "/")!,
            method: .put,
            parameters: ["is_read": true],
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    if response.response?.statusCode == 401 {
                        NotificationCenter.default.post(name: .signOutErrFlag, object: nil)
                    }
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

    public func deleteAllNotification(completion: @escaping (Bool?) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.notificationURL + "all/")!,
            method: .delete,
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.response?.statusCode == 204 else {
                    if response.response?.statusCode == 401 {
                        NotificationCenter.default.post(name: .signOutErrFlag, object: nil)
                    }
                    print("delete notifcation failed due to : \(String(describing: response.result.error))")
                    completion(false)
                    return
                }
                guard let scanResult = response.result.value else {
                    print("delete notifcation failed due to : Server Data Type Error")
                    completion(false)
                    return
                }
                completion(true)
        }
    }

    public func deleteNotification(notificationId: String, completion: @escaping (Bool?) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.notificationURL + notificationId+"/")!,
            method: .delete,
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.response?.statusCode == 204 else {
                    if response.response?.statusCode == 401 {
                        NotificationCenter.default.post(name: .signOutErrFlag, object: nil)
                    }
                    print("get notifcation failed due to : \(String(describing: response.result.error))")
                    completion(false)
                    return
                }
                guard let result = response.result.value else {
                    print("get notifcation failed due to : Server Data Type Error")
                    completion(false)
                    return
                }
                completion(true)
        }
    }

    public func answerNotification(notificationId: String, text: String, value: Int, answer: [Int], completion: @escaping(Bool) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.notificationAnswer)!,
            method: .post,
            parameters: ["text": text, "value": value, "notification": notificationId, "answer": answer],
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.response?.statusCode == 201 else {
                    if response.response?.statusCode == 401 {
                        NotificationCenter.default.post(name: .signOutErrFlag, object: nil)
                    }
                    print("response notifcation answer failed due to : \(String(describing: response.result.error))")
                    completion(false)
                    return
                }
                completion(true)
        }
    }

    public func updateFoodDiary(foodDiary: FoodDiaryModel, completion: @escaping(Bool) -> Void) {

        let params: Dictionary = ["food_name": foodDiary.foodInfoList[foodDiary.selectedFoodInfoPos].foodName, "image_id": foodDiary.imageId, "meal_type": foodDiary.mealType, "nutrient": assembleNutrtionString(foodDiary: foodDiary), "ingredient": assembleIngredientString(foodDiary: foodDiary), "search_type": foodDiary.recordType, "rank": String(foodDiary.selectedFoodInfoPos+1), "quantity": foodDiary.quantity, "unit": foodDiary.foodInfoList[foodDiary.selectedFoodInfoPos].portionList[foodDiary.selectedPortionPos].weightUnit] as [String: Any]
        Alamofire.request(
            URL(string: ServerConfig.foodDiaryURL+String(foodDiary.id)+"/")!,
            method: .put,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: [:])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("update food diary failed due to : \(String(describing: response.result.error))")
                    completion(false)
                    return
                }
                guard let result = response.result.value else {
                    print("update food diary failed due to : Server Data Type Error")
                    completion(false)
                    return
                }
//                let jsonObject = JSON(result)
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
    public func saveFoodDiary(userId: String, foodDiary: FoodDiaryModel, completion: @escaping (Bool, JSON) -> Void) {
        let params: Dictionary = ["food_name": foodDiary.foodInfoList[foodDiary.selectedFoodInfoPos].foodName, "image_id": foodDiary.imageId, "meal_type": foodDiary.mealType, "nutrient": assembleNutrtionString(foodDiary: foodDiary), "ingredient": assembleIngredientString(foodDiary: foodDiary), "search_type": foodDiary.recordType, "rank": String(foodDiary.selectedFoodInfoPos+1), "quantity": foodDiary.quantity, "unit": foodDiary.foodInfoList[foodDiary.selectedFoodInfoPos].portionList[foodDiary.selectedPortionPos].weightUnit] as [String: Any]
        Alamofire.request(
            URL(string: ServerConfig.foodDiaryURL+"?user_id="+userId)!,
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: [:])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("Save food diary failed due to : \(String(describing: response.result.error))")
                    completion(false, nil)
                    return
                }
                guard let result = response.result.value else {
                    print("Save food diary failed due to : Server Data Type Error")
                    completion(false, nil)
                    return
                }
                let jsonObject = JSON(result)
                completion(true, jsonObject)
        }
    }

    func assembleNutrtionString(foodDiary: FoodDiaryModel) -> String {
        let nutrientJson: JSON = [
            NutrtionData.calorieText: foodDiary.foodInfoList[foodDiary.selectedFoodInfoPos].calorie,
            NutrtionData.carbohydrateText: foodDiary.foodInfoList[foodDiary.selectedFoodInfoPos].carbohydrate,
            NutrtionData.proteinText: foodDiary.foodInfoList[foodDiary.selectedFoodInfoPos].protein,
            NutrtionData.fatText: foodDiary.foodInfoList[foodDiary.selectedFoodInfoPos].fat
        ]
        return nutrientJson.rawString()!
    }

    func assembleIngredientString(foodDiary: FoodDiaryModel) -> String {
        var ingredientString = ""
        if foodDiary.ingredientList.count == 0 {
            ingredientString = "[]"
        } else {
            ingredientString = "["
            for ingredient in  foodDiary.ingredientList {
                let json: JSON = [
                    "id": ingredient.id,
                    "ingredientId": ingredient.ingredientId,
                    "ingredientName": ingredient.ingredientName,
                    "calorie": ingredient.calorie,
                    "carbs": ingredient.carbs,
                    "protein": ingredient.protein,
                    "fat": ingredient.fat,
                    "quantity": ingredient.quantity,
                    "unit": ingredient.unit,
                    "weight": ingredient.weight
                ]
                ingredientString += json.rawString()! + ","
            }
            ingredientString = ingredientString.substring(to: ingredientString.index(before: ingredientString.endIndex))
            ingredientString += "]"
        }
        return ingredientString
    }

    public func uploadStepData(stepList: [StepEntity], completion: @escaping (Bool) -> Void) {
        var params = [String: Any]()
        var steps = [params]
        for step in stepList {
            var params = [String: Any]()
            let dateStr = DateUtil.templateDateToString(date: step.date!)
            params["date"] = dateStr
            params["value"] = step.stepValue
            steps.append(params)
        }
        params["steps"] = steps
        Alamofire.request(
            URL(string: ServerConfig.saveHourlyStepURL)!,
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.response?.statusCode == 201 else {
                    print("Save hourly step data failed due to : \(String(describing: response.result.error))")
                    completion(false)
                    return
                }
                completion(true)
        }
    }

    public func uploadStepData(userId: String, params: [String: Any], completion: @escaping (Bool) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.saveStepDiaryURL+"?user_id="+userId)!,
            method: .put,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
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
                completion(true)
        }
    }

    func getHealthLogByCategory(category: String, completion: @escaping ([HealthCenterItem]?) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.uploadHealthCenterData+"?category=" + category)!,
            method: .get,
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    if response.response?.statusCode == 401 {
                        NotificationCenter.default.post(name: .signOutErrFlag, object: nil)
                    }
                    print("Save exercise data failed due to : \(String(describing: response.result.error))")
                    completion(nil)
                    return
                }
                guard let result = response.result.value else {
                    print("Save exercise data failed due to : Server Data Type Error")
                    completion(nil)
                    return
                }
                let json = JSON(result)["results"]
                let healthRecordList = HealthCenterDataManager.instance.assembleHealthCenterItem(jsonArr: json)
                completion(healthRecordList)
        }
    }

    func getLatestHealthLog(completion: @escaping ([HealthCenterItem]?) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.healthCenterLogURL)!,
            method: .get,
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    if response.response?.statusCode == 401 {
                        NotificationCenter.default.post(name: .signOutErrFlag, object: nil)
                    }
                    print("Save exercise data failed due to : \(String(describing: response.result.error))")
                    completion(nil)
                    return
                }
                guard let result = response.result.value else {
                    print("Save exercise data failed due to : Server Data Type Error")
                    completion(nil)
                    return
                }
                let json = JSON(result)["data"]
                let healthRecordList = HealthCenterDataManager.instance.assembleHealthCenterMainData(jsonObj: json)
                completion(healthRecordList)
        }
    }

    //healthCenter logs
    func uploadHealthCenterData(userId: String, title: String, content: String, unit: String, amount: String, datetime: String, completion: @escaping (Bool) -> Void) {
        let params = ["title": title, "content": content, "unit": unit, "amount": amount, "datetime": datetime]
        Alamofire.request(
            URL(string: ServerConfig.saveHealthCenterDataURL+"?user_id="+userId)!,
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
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
                completion(true)
        }
    }

    func uploadHealthCenterData(category: String, value: Double, date: String, time: String, completion: @escaping (Bool) -> Void) {
        let params = ["category": category, "value": value, "date": date, "time": time] as [String: Any]
        Alamofire.request(URL(string: ServerConfig.uploadHealthCenterData)!,
                          method: .post,
                          parameters: params,
                          encoding: JSONEncoding.default,
                          headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("Save exercise data failed due to : \(String(describing: response.result.error))")
                    completion(false)
                    return
                }
                completion(true)
        }

    }

    //get dietary guide
    public func getDietaryGuideInfo(completion: @escaping ([String: Double]) -> Void) {
        var guideDict = [String: Double]()
        Alamofire.request(
            URL(string: ServerConfig.dietaryGuideURL)!,
            method: .get,
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    if response.response?.statusCode == 401 {
                        NotificationCenter.default.post(name: .signOutErrFlag, object: nil)
                    }
                    print("get Dietary Guide Failed due to : \(String(describing: response.result.error))")
                    completion(guideDict)
                    return
                }
                guard let value = response.result.value else {
                    print("get Dietary Guide Failed due to : Server Data Type Error")
                    completion(guideDict)
                    return
                }
                let json = JSON(value)
                guideDict["energy"] = json["data"]["energy"].doubleValue
                guideDict["protein"] = json["data"]["protein"].doubleValue
                guideDict["fat"] = json["data"]["fat"].doubleValue
                guideDict["carbohydrate"] = json["data"]["carbohydrate"].doubleValue
                completion(guideDict)
        }
    }

    //daily nutrition sum
    func getDailySum(source: UIViewController, date: Date, completion: @escaping ([String: Double]) -> Void) {
        let dateStr = DateUtil.normalDateToString(date: date)
        let param = ["date": dateStr]
        var responseDict = [:] as [String: Double]
        Alamofire.request(
            URL(string: ServerConfig.nutritionDailySum)!,
            method: .post,
            parameters: param,
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    if response.response?.statusCode == 401 {
                        NotificationCenter.default.post(name: .signOutErrFlag, object: nil)
                    }
                    print("Get Daily Sum failed due to : \(String(describing: response.result.error))")
                    completion(responseDict)
                    return
                }
                guard let result = response.result.value else {
                    print("Get Daily Sum failed due to : Server Data Type Error")
                    completion(responseDict)
                    return
                }
                let jsonObject = JSON(result)["data"]
                responseDict["energy"] = jsonObject["energy"].doubleValue
                responseDict["protein"] = jsonObject["protein"].doubleValue
                responseDict["fat"] = jsonObject["fat"].doubleValue
                responseDict["carbohydrate"] = jsonObject["carbohydrate"].doubleValue
                completion(responseDict)
        }
    }

    func handleAuthenticationException(statusCode: Int, sourceViewController: UIViewController) {
        if statusCode == 401 {
            if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as? LoginViewController {
                sourceViewController.present(dest, animated: true, completion: nil)
            }
        }
    }

    //cancel task
    func cancelRequest(requestURL: String) {
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach {
                if $0.originalRequest?.url?.absoluteString == requestURL {
                    $0.cancel()
                }
            }
            uploadData.forEach { $0.cancel() }
            downloadData.forEach { $0.cancel() }
        }
    }

    //cancel all task
    func cancelAllRequest() {
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach {
                $0.cancel()
            }
            uploadData.forEach { $0.cancel() }
            downloadData.forEach { $0.cancel() }
        }
    }
    //basic authentication header
    func getBasicAuthenticationHeader() -> [String: String] {
        let preferences = UserDefaults.standard
        let userName = preferences.string(forKey: PreferenceKey.userNameKey)
        let password = preferences.string(forKey: PreferenceKey.passwordKey)
        let credentialData = "\(userName):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString(options: [])
        let headers = ["Authorization": "Basic \(base64Credentials)"]
        return headers
    }

    //for all the new token
    func getTokenHeader() -> [String: String] {
//        let header = ["Authorization": "Token 5b6f69c1ffb0b02413901dda8d01d088e8d31b43"]
        let preferences = UserDefaults.standard
        let token = preferences.string(forKey: PreferenceKey.tokenKey) ?? ""
//        let userAgent = "DietLens/1.1 (com.sg.next.wellness.DietLens; build:1.0.3; iOS 11.4.0) Alamofire/4.7.3"
        let header = ["Authorization": "Token "+token, "User-Agent": getUserAgentString()]
        return header
    }

    func getUserAgentString() -> String {
        let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
//        let appIdentifier = Bundle.main.bundleIdentifier!
        let systemIOSVersion = UIDevice.current.systemVersion
        let modelName = UIDevice.modelName
//        let reqeustToolVersion = ""
        return appName + "/" + appVersion + " (iOS; " + "build:" + buildVersion + "; system version " + systemIOSVersion + ")" + modelName
    }

    //special header for webhook
    func getHardCodeBasicAuthenticationHeader() -> [String: String] {
        let header = ["Authorization": "Basic YThkMjM2MzYxZmRkZjJmZTlmZmYxNjE2ZTAzNzU1NDI6ODYwMzBiZWVkMjEyNGY0YmRjZmU3MGU3YzE4YTA1YmI="]
        return header
    }

}
