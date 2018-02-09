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
        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss"
        for i in 0..<jsonArr.count {
            var jsonobj = jsonArr[i]
            var notification = NotificationModel()
            notification.id = jsonobj["id"].stringValue
            notification.title = jsonobj["title"].stringValue
            notification.body = jsonobj["content"].stringValue
            let dateStr = jsonobj["created_time"].stringValue.split(separator: ".")[0]
            let date = RFC3339DateFormatter.date(from: String(dateStr))
            notification.dateReceived = date!
            if jsonobj["status"].stringValue == "read"{
                notification.read = true
            } else {
                notification.read = false
            }
            notifications.append(notification)
        }
        return notifications
    }
}
