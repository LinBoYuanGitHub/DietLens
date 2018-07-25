//
//  EmailValidtor.swift
//  DietLens
//
//  Created by linby on 2018/7/24.
//  Copyright © 2018 NExT++. All rights reserved.
//

import Foundation

class TextValidtor {

    class func isValidEmail(testStr: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
}
