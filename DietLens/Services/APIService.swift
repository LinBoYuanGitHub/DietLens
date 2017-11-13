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

    public func loginRequest(userEmail: String, password: String, completion: @escaping (_ isSuccess: Bool) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.userLoginURL)!,
            method: .post,
            parameters: ["email": userEmail, "pwd": password])
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

    public func thirdPartyLoginRequest(appUserId: String, nickName: String, platform: String, completion: @escaping (_ isSuccess: Bool) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.thirdPartyLoginURL)!,
            method: .post,
            parameters: ["id": appUserId, "nickname": nickName, "platform": platform])
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

    public func register(nickName: String, email: String, password: String, completion: @escaping (_ isSuccess: Bool) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.thirdPartyLoginURL)!,
            method: .post,
            parameters: ["nickname": nickName, "email": email, "password": password])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("Register Failed due to : \(String(describing: response.result.error))")
                    completion(false)
                    return
                }
                guard let value = response.result.value as? JSON else {
                    print("Register failed due to : Server Data Type Error")
                    completion(false)
                    return
                }
                let userId = value["id"].stringValue
                completion(true)
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

    public func getFoodSearchResult(keywords: String, completion: @escaping ([TextSearchSuggestionEntity]?) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.foodSearchListURL)!,
            method: .post,
            parameters: ["text": keywords])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("Get search result failed due to : \(String(describing: response.result.error))")
                    completion(nil)
                    return
                }
                guard let searchResults = response.result.value as? [JSON] else {
                    print("Get searchResult failed due to : Server Data Type Error")
                    completion(nil)
                    return
                }
                var foodSearchList = [TextSearchSuggestionEntity]()
                for item in searchResults {
                    foodSearchList.append(
                        TextSearchSuggestionEntity(id: item["id"].intValue, name: item["name"].stringValue))
                }
                completion(foodSearchList)
        }
    }

    public func getFoodSearchDetailResult(foodId: Int, completion: @escaping (FoodInfomation?) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.foodSearchDetailURL)!,
            method: .post,
            parameters: ["id": foodId])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                print("Get food detail failed due to : \(String(describing: response.result.error))")
                completion(nil)
                    return
                }
                guard let detail = response.result.value as? JSON else {
                    print("Get food detail failed due to : Server Data Type Error")
                    completion(nil)
                    return
                }
                let foodInfo = FoodInfoDataManager.instance.assembleFoodInfo(jsonObject: detail)
                completion(foodInfo)
        }
    }

    public func getBarcodeScanResult(barcode: String, completion: @escaping (FoodInfomation?) -> Void) {
        Alamofire.request(
            URL(string: ServerConfig.barcodeSearchURL)!,
            method: .post,
            parameters: ["barcode": barcode])
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("Get search result failed due to : \(String(describing: response.result.error))")
                    completion(nil)
                    return
                }
                guard let scanResult = response.result.value as? JSON else {
                    print("Get searchResult failed due to : Server Data Type Error")
                    completion(nil)
                    return
                }
                let barcodeScanResult = FoodInfoDataManager.instance.assembleFoodInfo(jsonObject: scanResult)
                completion(barcodeScanResult)
        }
    }

    public func uploadRecognitionImage(imgData: Data, userId: String) {
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
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                upload.responseJSON { response in
                    print(response.result.value)
                }
            case .failure(let encodingError):
                print(encodingError)
            }
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
    public func saveFoodDiary(foodDiary: FoodDiary, imageUrl: String, fileName: String, mealTime: String, mealType: String, recordType: String, category: String, ratio: Float, completion: @escaping (Bool) -> Void) {
        var params: Dictionary = ["rank": foodDiary.rank, "user_id": "", "image_url": imageUrl, "file_name": fileName, "mealtime": mealTime, "mealType": mealType, "search_type": recordType, "portion_size": ratio, "calorie": foodDiary.calorie, "carbohydrate": foodDiary.carbohydrate, "protein": foodDiary.protein, "fat": foodDiary.fat] as [String: Any]
        if recordType == "Image"{
            params["food_id"] = foodDiary.id
        } else if recordType == "Text"{
            params["textfood_id"] = foodDiary.id
            params["category"] = category
        } else if recordType == "Barcode"{
            params["barcodefood_id"] = foodDiary.id
            params["category"] = "BarcodeItems"
        } else {
            params["customizefood"] = foodDiary.foodName
        }
        Alamofire.request(
            URL(string: ServerConfig.saveFoodDiaryURL)!,
            method: .post,
            parameters: params)
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("Save food diary failed due to : \(String(describing: response.result.error))")
                    completion(false)
                    return
                }
                guard let result = response.result.value as? JSON else {
                    print("Save food diary failed due to : Server Data Type Error")
                    completion(false)
                    return
                }
                completion(true)
        }
    }

}
