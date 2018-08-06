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
            let notification = assembleSingleUserNotification(jsonobj: jsonArr[index])
            notifications.append(notification)
        }
        return notifications
    }

    func assembleSingleUserNotification(jsonobj: JSON) -> NotificationModel {
        var notification = NotificationModel()
        notification.id = jsonobj["id"].stringValue
        notification.title = jsonobj["title"].stringValue
        notification.body = jsonobj["message_body"].stringValue
        notification.content = jsonobj["content"].stringValue
        notification.prompt = jsonobj["prompt"].stringValue
        notification.messageType = jsonobj["message_type"].stringValue
        notification.responseType = jsonobj["response_type"].stringValue
        for json in jsonobj["response_options"].arrayValue {
            notification.responseOptions.append(json.stringValue)
        }
        let dateStr = String(jsonobj["created_time"].stringValue.split(separator: ".")[0])
        let createDate = DateUtil.standardStringToDate(dateStr: dateStr)
        notification.createTime = createDate
        notification.dateReceived = Date()
        notification.imgUrl = jsonobj["img_url"].stringValue
        notification.read = jsonobj["is_read"].boolValue
        return notification
    }

}
