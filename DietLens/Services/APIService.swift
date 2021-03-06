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
import GoogleSignIn

// swiftlint:disable all
class APIService {

    static var instance = APIService()

    private init() {

    }

    public func postRequest(url: String, params: [String: Any], successCompletion:@escaping (_ result: JSON) -> Void, failureCompletion: @escaping (_ errorMessage: String) -> Void) {
        guard let urlLink: URL = URL(string: url) else {
            return
        }
        Alamofire.request(urlLink,
                          method: .post,
                          parameters: params,
                          encoding: JSONEncoding.default,
                          headers: getTokenHeader())
            .validate()
            .responseJSON {(response) -> Void in
                guard response.result.isSuccess else {
                    print("request failed due to : \(String(describing: response.result.error))")
                    if response.response?.statusCode == 401 {
                        self.popOutToLoginPage()
                        return
                    }
                    //get error message from the err json data
                    if let errorJsonString = String(data: response.data!, encoding: String.Encoding.utf8) {
                        let errJSON = errorJsonString.data(using: String.Encoding.utf8).flatMap({try? JSON(data: $0)}) ?? JSON(NSNull())
                        failureCompletion(errJSON["message"].stringValue)
                    }
                    return
                }
                guard let parseResult = response.result.value else {
                    failureCompletion("Json parse error")
                    return
                }
                let result = JSON(parseResult)
                successCompletion(result)
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

    public func googleIdValidationRequest(accessToken: String, uuid: String, completion:@escaping (_ isSuccess: Bool, _ isNewUser: Bool) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.googleIdValidationURL)!,
            method: .post,
            parameters: ["access_token": accessToken, "uid": uuid],
            encoding: JSONEncoding.default,
            headers: [:])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("google uid validation failed")
                    completion(false, false)
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
                guard let parseResult = response.result.value else {
                    completion(false, false)
                    return
                }
                let userId = JSON(parseResult)["data"]["id"].stringValue
                preferences.setValue(userId, forKey: PreferenceKey.userIdkey)
                //get isNewUser flag
                let isNewUser = JSON(parseResult)["data"]["is_new_user"].boolValue
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
                guard let parseResult = response.result.value else {
                    completion(false)
                    return
                }
                let jsonObj = JSON(parseResult)
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
                guard let parseResult = response.result.value else {
                    completion(false)
                    return
                }
                let jsonObj = JSON(parseResult)
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
                guard (response.result.value as? JSON) != nil else {
                    print("Login Failed due to : Server Data Type Error")
                    completion(false)
                    return
                }
                completion(true)
        }
    }

    public func register(email: String, password: String, completion: @escaping (_ isSuccess: Bool) -> Void, failedCompletion: @escaping(_ failedMsg: String) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.registry)!,
            method: .post,
            parameters: ["email": email, "password": password],
            encoding: JSONEncoding.default,
            headers: [:])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    completion(false)
                    return
                }
                guard let parseResult = response.result.value else {
                    completion(false)
                    return
                }
                let jsonObj = JSON(parseResult)
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
                    if response.response?.statusCode == 401 {
                        self.popOutToLoginPage()
                        return
                    }
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
                    if response.response?.statusCode == 401 {
                        self.popOutToLoginPage()
                        return
                    }
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
                    if response.response?.statusCode == 401 {
                        self.popOutToLoginPage()
                        return
                    }
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
                    if response.response?.statusCode == 401 {
                        self.popOutToLoginPage()
                        return
                    }
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
                        self.popOutToLoginPage()
                        return
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
                let foodSearchList = TextSearchDataManager.instance.assembleTextSerchResultList(jsonObj: jsonObj)
                //                let jsonArr = jsonObj["data"]
                let nextLink = jsonObj["next"].stringValue
                nextPageCompletion(nextLink)
                completion(foodSearchList)
        }
    }

    public func getFoodSearchResult(filterType: Int, keywords: String, latitude: Double, longitude: Double, completion: @escaping ([TextSearchSuggestionEntity]?) -> Void, nextPageCompletion: @escaping (String?) -> Void) {
        let url = ServerConfig.foodFullTextSearchURL
        self.getFoodSearchResult(requestUrl: url, keywords: keywords, latitude: latitude, longitude: longitude, completion: completion, nextPageCompletion: nextPageCompletion)
    }

    public func getFoodSearchPopularity(mealtime: String, completion: @escaping ([TextSearchSuggestionEntity]?) -> Void, nextPageCompletion: @escaping (String?) -> Void) {
        let url =  ServerConfig.textSearchPopularURL+"?meal="+mealtime
        self.getFoodSearchPopularity(requestUrl: url, mealtime: mealtime, completion: completion, nextPageCompletion: nextPageCompletion)
    }

    public func getFavouriteFoodList(completion: @escaping ([TextSearchSuggestionEntity]?) -> Void, nextPageCompletion: @escaping (String?) -> Void) {
        let url = ServerConfig.favouriteFoodURL
        self.getFavouriteFoodList(requestUrl: url, completion: completion, nextPageCompletion: nextPageCompletion)
    }

    public func removeFavouriteFood(removeFoodId: Int, completion: @escaping(Bool) -> Void) {
        postRequest(url: ServerConfig.favouriteFoodURL + "remover/", params: ["food": removeFoodId], successCompletion: { (_) in
            completion(true)
        }) { (_) in
            completion(false)
        }
    }

    public func getFavouriteFoodList(requestUrl: String, completion: @escaping ([TextSearchSuggestionEntity]?) -> Void, nextPageCompletion: @escaping (String?) -> Void) {
        Alamofire.request(
            URL(string: requestUrl)!,
            method: .get,
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("Get search result failed due to : \(String(describing: response.result.error))")
                    if response.response?.statusCode == 401 {
                        self.popOutToLoginPage()
                        return
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
                let foodSearchList = TextSearchDataManager.instance.assembleFavouriteFoodResultList(jsonObj: jsonObj)
                let nextLink = jsonObj["next"].stringValue
                nextPageCompletion(nextLink)
                completion(foodSearchList)
        }
    }

    public func getFoodSearchPopularity(requestUrl: String, mealtime: String, completion: @escaping ([TextSearchSuggestionEntity]?) -> Void, nextPageCompletion: @escaping (String?) -> Void) {
        Alamofire.request(
            URL(string: requestUrl)!,
            method: .get,
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("Get search result failed due to : \(String(describing: response.result.error))")
                    if response.response?.statusCode == 401 {
                        self.popOutToLoginPage()
                        return
                    }
                    //return only when the search is cancelled
                    if (response.error as NSError?)?.code == NSURLErrorCancelled {
                        return
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
                let foodSearchList = TextSearchDataManager.instance.assemblePopularTextSerchResultList(jsonObj: jsonObj)
                let nextLink = jsonObj["next"].stringValue
                nextPageCompletion(nextLink)
                completion(foodSearchList)
        }
    }

    public func setFavouriteFoodList(foodList: [Int], completion: @escaping (Bool) -> Void) {
        postRequest(url: ServerConfig.favouriteFoodURL, params: ["food": foodList], successCompletion: { (_) in
            completion(true)
        }) { (_) in
            completion(false)
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
                for index in 0..<jsonArr.count {
                    let entity = TextSearchSuggestionEntity(id: (jsonArr[index].dictionaryValue["id"]?.intValue)!, name: (jsonArr[index].dictionaryValue["name"]?.stringValue)!, useExpImage: false, expImagePath: "")
                    foodSearchList.append(entity)
                }
                completion(foodSearchList)
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
        let downloadURL = ServerConfig.qiniuDietLensImageDomain + imageKey+"?imageView2/5/w/"+String(width)+"/h/"+String(height)
        let downloadImageView = UIImageView()
        let url = URL(string: downloadURL)!
        downloadImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "loading_img"), options: [], progressBlock: nil) { (image, _, _, _) in
            completion(image)
        }
    }

    public func qiniuImageDownload(imageKey: String, completion: @escaping (UIImage?) -> Void) {
        let downloadURL = ServerConfig.qiniuDietLensImageDomain + imageKey
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
    public func postForRecognitionResult(imageKey: String, latitude: Double, longitude: Double, uploadSpeed: TimeInterval, completion: @escaping ([DisplayFoodCategory]?, _ taskId: String) -> Void) {
        postRequest(url: ServerConfig.uploadImageKeyURL, params: ["key": imageKey, "latitude": latitude, "longitude": longitude, "upload_speed": uploadSpeed], successCompletion: { (result) in
            let jsonObject = result["data"]
            let taskId = result["task_id"].stringValue
            let displayCategory = FoodInfoDataManager.instance.assembleDisplayFoodCategoryData(data: jsonObject)
            completion(displayCategory, taskId)
            print("success")
        }) { (_) in
            completion(nil, "")
        }
    }

    public func postForMixVegResults(imgData: Data, completion: @escaping (FoodDiaryEntity?) -> Void) {
        Alamofire.upload(multipartFormData: { multipart in
            multipart.append(imgData, withName: "image", fileName: "image.jpg", mimeType: "image/jpeg")
        }, to: ServerConfig.uploadMixVegDishURL, method: .post, headers: getTokenHeader()) { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.response { result in
                    guard let data = result.data else { return }
                    let jsonObj = JSON(data)
                    let foodDiary = FoodInfoDataManager.instance.assembleFoodDiaryEntity(jsonObject: jsonObj)
                    completion(foodDiary)
                }
                upload.uploadProgress { _ in
                    //call progress callback here if you need it
                }
            case .failure(let encodingError):
                print("multipart upload encodingError: \(encodingError)")
            }
        }
    }

    public func postForMixVegResults(taskId: String, completion:@escaping (FoodDiaryEntity?) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.uploadMixVegDishURL)!,
            method: .post,
            parameters: ["task_id": taskId],
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    if response.response?.statusCode == 401 {
                        self.popOutToLoginPage()
                        return
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
                    let foodDiaryEntity = FoodInfoDataManager.instance.assembleMixVegFoodDiaryEntity(jsonObject: jsonObject["data"])
                    completion(foodDiaryEntity)
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
                        self.popOutToLoginPage()
                        return
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
        //UI update observer notify
        NotificationCenter.default.post(name: .shouldRefreshFoodDiary, object: nil)
        //request part
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
                        self.popOutToLoginPage()
                        return
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
        //UI update observer notify
        NotificationCenter.default.post(name: .shouldRefreshFoodDiary, object: nil)
        //request part
        Alamofire.request(
            URL(string: ServerConfig.foodDiaryDietLogs+foodDiaryId+"/")!,
            method: .delete,
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    if response.response?.statusCode == 401 {
                        self.popOutToLoginPage()
                        return
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
                        self.popOutToLoginPage()
                        return
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
    public func updateFoodDiary(isPartialUpdate: Bool, foodDiary: FoodDiaryEntity, completion:@escaping(Bool, FoodDiaryEntity?) -> Void) {
        var param: [String: Any] = [:]
        if isPartialUpdate {
            param = FoodInfoDataManager.instance.partialParamfyFoodDiaryEntity(foodDiaryEntity: foodDiary)
        } else {
            param = FoodInfoDataManager.instance.paramfyFoodDiaryEntity(foodDiaryEntity: foodDiary)
        }

        //UI update observer notify
        NotificationCenter.default.post(name: .shouldRefreshFoodDiary, object: nil)
        //request part
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
                        self.popOutToLoginPage()
                        return
                    }
                    print("update foodDiary failed due to : \(String(describing: response.result.error))")
                    completion(false, nil)
                    return
                }
                guard let result = response.result.value else {
                    print("update foodDiary failed due to : Server Data Type Error")
                    completion(false, nil)
                    return
                }
                let jsonObject = JSON(result)
                let entity = FoodDiaryDataManager.instance.assembleFoodDiaryEntity(jsonObject: jsonObject)
                completion(true, entity)
        }
    }
    //create a new foodDiary -> save FoodItem & success
    public func createFooDiary(foodDiary: FoodDiaryEntity, completion:@escaping(Bool) -> Void) {
        let param = FoodInfoDataManager.instance.paramfyFoodDiaryEntity(foodDiaryEntity: foodDiary)
        //UI update observer notify
        NotificationCenter.default.post(name: .shouldRefreshFoodDiary, object: nil)
        //request part
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
                        self.popOutToLoginPage()
                        return
                    }
                    print("create foodDiary failed due to : \(String(describing: response.result.error))")
                    completion(false)
                    return
                }
                guard response.result.value != nil else {
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
                        self.popOutToLoginPage()
                        return
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
                        self.popOutToLoginPage()
                        return
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
        }, to: ServerConfig.uploadRecognitionURL) { (result) in
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
                    let resultList = FoodInfoDataManager.instance.assembleFoodInfoData(data: resultObj["data"])
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
                        self.popOutToLoginPage()
                        return
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
                        self.popOutToLoginPage()
                        return
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
                    if response.response?.statusCode == 401 {
                        self.popOutToLoginPage()
                        return
                    }
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
        Alamofire.request(
            URL(string: ServerConfig.userURL + "/" + userId + "/")!,
            method: .put,
            parameters: ["name": profile.name, "activity_level": String(profile.activityLevel), "gender": String(profile.gender), "height": profile.height, "weight": profile.weight, "birthday": profile.birthday, "ethnicity": profile.ethnicity],
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    if response.response?.statusCode == 401 {
                        self.popOutToLoginPage()
                        return
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
        Alamofire.request(
            URL(string: ServerConfig.userURL + "/" + userId! + "/")!,
            method: .put,
            parameters: ["name": name, "gender": String(gender), "height": height, "weight": weight, "birthday": birthday],
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    if response.response?.statusCode == 401 {
                        self.popOutToLoginPage()
                        return
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
                        self.popOutToLoginPage()
                        return
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
                        self.popOutToLoginPage()
                        return
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
                        self.popOutToLoginPage()
                        return
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
                        self.popOutToLoginPage()
                        return
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
                        self.popOutToLoginPage()
                        return
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
                        self.popOutToLoginPage()
                        return
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
                        self.popOutToLoginPage()
                        return
                    }
                    print("response notifcation answer failed due to : \(String(describing: response.result.error))")
                    completion(false)
                    return
                }
                completion(true)
        }
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
                    if response.response?.statusCode == 401 {
                        self.popOutToLoginPage()
                        return
                    }
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
                    if response.response?.statusCode == 401 {
                        self.popOutToLoginPage()
                        return
                    }
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
                    print("Save exercise data failed due to : \(String(describing: response.result.error))")
                    if response.response?.statusCode == 401 {
                        self.popOutToLoginPage()
                        return
                    }
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
                    print("Save exercise data failed due to : \(String(describing: response.result.error))")
                    if response.response?.statusCode == 401 {
                        self.popOutToLoginPage()
                        return
                    }
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
                    if response.response?.statusCode == 401 {
                        self.popOutToLoginPage()
                        return
                    }
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

    func deleteHealthCenterData(healthItemId: String, completion: @escaping (Bool) -> Void) {
        Alamofire.request(URL(string: ServerConfig.uploadHealthCenterData + healthItemId + "/")!,
                          method: .delete,
                          encoding: JSONEncoding.default,
                          headers: getTokenHeader())
        .validate()
        .responseJSON { (response) -> Void in
            guard response.result.isSuccess else {
                print("Save exercise data failed due to : \(String(describing: response.result.error))")
                if response.response?.statusCode == 401 {
                    self.popOutToLoginPage()
                    return
                }
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
                    if response.response?.statusCode == 401 {
                        self.popOutToLoginPage()
                        return
                    }
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
                    print("get Dietary Guide Failed due to : \(String(describing: response.result.error))")
                    if response.response?.statusCode == 401 {
                        self.popOutToLoginPage()
                        return
                    }
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
                    print("Get Daily Sum failed due to : \(String(describing: response.result.error))")
                    if response.response?.statusCode == 401 {
                        self.popOutToLoginPage()
                        return
                    }
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

    //diet-goal
    func getDietGoal(completion: @escaping ([String: Double]) -> Void) {
        var guideDict = [String: Double]()
        Alamofire.request(
            URL(string: ServerConfig.dietGoalURL)!,
            method: .get,
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("get Dietary Guide Failed due to : \(String(describing: response.result.error))")
                    if response.response?.statusCode == 401 {
                        self.popOutToLoginPage()
                        return
                    }
                    completion(guideDict)
                    return
                }
                guard let value = response.result.value else {
                    print("get Dietary Goal Failed due to : Server Data Type Error")
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

    func setCalorieGoal(calorieGoal: Double, completion: @escaping (Bool) -> Void) {
        let userId = UserDefaults.standard.string(forKey: PreferenceKey.userIdkey) ?? ""
        Alamofire.request(
            URL(string: ServerConfig.dietGoalURL + userId + "/")!,
            method: .put,
            parameters: ["energy": calorieGoal],
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("Set calorie goal failed due to : \(String(describing: response.result.error))")
                    return
                }
                completion(response.result.isSuccess)
        }
    }

    //SMS Login

    func sendSMSRequest(phoneNumber: String, completion: @escaping (Bool) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.phoneSendSMSURL)!,
            method: .post,
            parameters: ["phone": phoneNumber],
            encoding: JSONEncoding.default,
            headers: [:])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("Get Daily Sum failed due to : \(String(describing: response.result.error))")
                    return
                }
                completion(response.result.isSuccess)
        }
    }

    func verifySMSRequest(phoneNumber: String, smsToken: String, completion: @escaping (Bool) -> Void, failureCompletion: @escaping (String) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.verifySMSURL)!,
            method: .post,
            parameters: ["phone": phoneNumber, "sms_token": smsToken],
            encoding: JSONEncoding.default,
            headers: [:])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    if let errorJsonString = String(data: response.data!, encoding: String.Encoding.utf8) {
                        let errJSON = errorJsonString.data(using: String.Encoding.utf8).flatMap({try? JSON(data: $0)}) ?? JSON(NSNull())
                         failureCompletion(errJSON["message"].stringValue)
                    }
                    print("Verify SMS Code failed due to : \(String(describing: response.result.error))")
                    return
                }
                guard (response.response?.allHeaderFields) != nil else {
                    completion(false)
                    print("Get Token failed")
                    return
                }
                let preferences = UserDefaults.standard
                let token = response.response!.allHeaderFields["token"]
                let jsonObj = JSON(response.result.value)
                preferences.setValue(jsonObj["data"]["id"].stringValue, forKey: PreferenceKey.userIdkey)
                preferences.setValue(jsonObj["data"]["name"].stringValue, forKey: PreferenceKey.nickNameKey)
                preferences.setValue(token, forKey: PreferenceKey.tokenKey)
                completion(response.result.isSuccess)
        }
    }

    //clinical study

    func getClinicalStudyList(completion: @escaping ([ClinicalStudyEntity]) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.studyListURL)!,
            method: .get,
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("get clinical study failed due to : \(String(describing: response.result.error))")
                    let list = [ClinicalStudyEntity]()
                    completion(list)
                    return
                }
                let jsonArr = JSON(response.result.value)
                let clinicalStudyList = ClinicalStudyDataManager.instance.assembleClinicalStudyDataEntity(jsonArr: jsonArr)
                completion(clinicalStudyList)
        }
    }

    func getClinicalStudyDetail(groupId: String, completion: @escaping (ClinicalStudyEntity?) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.studyListURL + groupId + "/")!,
            method: .get,
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("get clinical study failed due to : \(String(describing: response.result.error))")
                    completion(nil)
                    return
                }
                let jsonObj = JSON(response.result.value)
                let clinicalStudyEntity = ClinicalStudyDataManager.instance.assembleClinicalStudyDetailEntity(jsonObj: jsonObj)
                completion(clinicalStudyEntity)
        }
    }

    func connectToStudyGroup(groupId: String, completion: @escaping (Bool) -> Void, failedCompletion: @escaping (String) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.studyListURL)!,
            method: .post,
            parameters: ["study_group_id": groupId],
            encoding: JSONEncoding.default,
            headers: getTokenHeader())
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("connect to study group failed due to : \(String(describing: response.result.error))")
                    let message = JSON(response.result.value)["message"].stringValue
                    failedCompletion(message)
                    return
                }
                completion(response.result.isSuccess)
        }
    }

    /**********************************************************
     APIService Task
    **********************************************************/

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
        let preferences = UserDefaults.standard
        var header = ["User-Agent": getUserAgentString()]
        if let token = preferences.string(forKey: PreferenceKey.tokenKey) {
            header = ["Authorization": "Token "+token, "User-Agent": getUserAgentString()]
        }
        return header
    }

    func getUserAgentString() -> String {
        if let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as? String,
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            let systemIOSVersion = UIDevice.current.systemVersion
            let modelName = UIDevice.modelName
            return appName + "/" + appVersion + " (iOS; " + "build:" + buildVersion + "; system version " + systemIOSVersion + ")" + modelName
        }
        return ""
    }

    func popOutToLoginPage() {
        let preferences = UserDefaults.standard
        let token = preferences.string(forKey: PreferenceKey.tokenKey)
        if token == nil {
            return
        }
        if var rootVC = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = rootVC.presentedViewController {
                rootVC = presentedViewController
            }
            DispatchQueue.main.async {
                AlertMessageHelper.showMessage(targetController: rootVC, title: "Message", message: "You already login the same account in another device. Please check.", confirmText: "OK") {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let welcomeNVC = storyboard.instantiateViewController(withIdentifier: "WelcomeNVC")
                    AlertMessageHelper.alertController?.dismiss(animated: true, completion: nil)
                    rootVC.present(welcomeNVC, animated: true, completion: nil)
                    self.clearPersonalData()
                }
            }
        }
    }

    func clearPersonalData() {
        let preferences = UserDefaults.standard
        preferences.setValue(nil, forKey: PreferenceKey.userIdkey)
        preferences.setValue(nil, forKey: PreferenceKey.facebookId)
        preferences.setValue(nil, forKey: PreferenceKey.tokenKey)
        preferences.setValue(nil, forKey: PreferenceKey.nickNameKey)
        preferences.setValue(nil, forKey: PreferenceKey.googleUserId)
        preferences.setValue(nil, forKey: PreferenceKey.googleImageUrl)
        //google login
        GIDSignIn.sharedInstance().signOut()
    }

}
