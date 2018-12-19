//
//  NotificationName.swift
//  DietLens
//
//  Created by linby on 12/12/2017.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation
extension Notification.Name {
    static let addDiaryDismiss = Notification.Name("adddiarydismiss")
    static let didReceiveNotification = Notification.Name("didreceivenotification")
    static let onIngredientPlusBtnClick = Notification.Name("oningredientplusbtnclick")
    static let addIngredient = Notification.Name("addingredient")
    static let onSideMenuClick = Notification.Name("onsidemenuclick")
    static let shouldRefreshMainPageNutrition = Notification.Name("shouldrefreshmainpagenutrition")
    static let shouldRefreshSideBarHeader = Notification.Name("shouldRefreshSideBarHeader")
    static let signOutErrFlag = Notification.Name("signOutErrorFlag")
    static let shouldRefreshFoodDiary = Notification.Name("shouldRefreshFoodDiary")
}
