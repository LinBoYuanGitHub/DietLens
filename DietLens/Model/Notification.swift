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
    public var body: String = ""
    public var title: String = ""
    public var read: Bool = false
    public var dateReceived = Date()
}
