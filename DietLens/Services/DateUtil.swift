//
//  DateUtil.swift
//  DietLens
//
//  Created by linby on 01/03/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import Foundation
class DateUtil{
    
    public static func StandardStringToDate(dateStr:String) -> Date{
        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss"
        let resultDate = RFC3339DateFormatter.date(from: String(dateStr))
        return resultDate!
    }
    
    public static func StandardDateToString(date:Date) -> String{
        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss"
        let resultStr = RFC3339DateFormatter.string(from: date)
        return resultStr
    }
    
    
}
