//
//  Notification.swift
//  DietLens
//
//  Created by next on 29/11/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation

struct NotificationModel {
    public var id: String = ""
    public var title: String = ""
    public var body: String = ""
    public var content: String = ""
    public var prompt: String = ""
    public var imgUrl = ""
    public var responseType = "1"
    public var responseOptions = [String]()
    public var read: Bool = false
    public var dateReceived = Date()
    public var createTime = Date()
    public var messageType = ""
}
