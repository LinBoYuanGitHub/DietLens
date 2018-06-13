//
//  NotificationDataManager.swift
//  DietLens
//
//  Created by linby on 28/01/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import Foundation
import SwiftyJSON

class NotificationDataManager {
    static var instance = NotificationDataManager()
    private init() {}

    func assembleUserNotification(jsonArr: JSON) -> [NotificationModel] {
        var notifications = [NotificationModel]()
        for index in 0..<jsonArr.count {
            var jsonobj = jsonArr[index]
            var notification = NotificationModel()
            notification.id = jsonobj["id"].stringValue
            notification.title = jsonobj["title"].stringValue
            notification.body = jsonobj["message_body"].stringValue
            notification.content = jsonobj["content"].stringValue
            notification.prompt = jsonobj["prompt"].stringValue
            notification.responseType = jsonobj["response_type"].stringValue
            for json in jsonobj["response_options"].arrayValue {
                notification.responseOptions.append(json.stringValue)
            }
            notification.dateReceived = Date()
            notification.imgUrl = jsonobj["img_url"].stringValue
            notification.read = jsonobj["is_read"].boolValue
            notifications.append(notification)
        }
        return notifications
    }

}
