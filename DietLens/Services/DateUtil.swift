//
//  DateUtil.swift
//  DietLens
//
//  Created by linby on 01/03/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import Foundation
class DateUtil {

    public static func standardStringToDate(dateStr: String) -> Date {
        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss"
        let resultDate = RFC3339DateFormatter.date(from: String(dateStr))
        return resultDate!
    }

    public static func standardDateToString(date: Date) -> String {
        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd"
        let resultStr = RFC3339DateFormatter.string(from: date)
        return resultStr
    }

    public static func normalStringToDate(dateStr: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        let resultDate = dateFormatter.date(from: String(dateStr))
        return resultDate!
    }

    public static func normalDateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let resultStr = dateFormatter.string(from: date)
        return resultStr
    }

    public static func templateStringToDate(dateStr: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let resultDate = dateFormatter.date(from: String(dateStr))
        return resultDate!
    }

    public static func templateDateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let resultStr = dateFormatter.string(from: date)
        return resultStr
    }

    public static func day3MDateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM"
        let resultStr = dateFormatter.string(from: date)
        return resultStr
    }

    public static func formatGMTDateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        let resultStr = dateFormatter.string(from: date)
        return resultStr
    }

    public static func formatMonthToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        let resultStr = dateFormatter.string(from: date)
        return resultStr
    }

}
