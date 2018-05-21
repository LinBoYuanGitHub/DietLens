//
//  EncryptionUtil.swift
//  DietLens
//
//  Created by linby on 27/04/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import Foundation
import CryptoSwift

class EncryptionUtil {

    public static func generateQiniuDownloadToken(originalURL: String, accessKey: String) -> String {
        do {
            let hmac = try HMAC(key: QiniuConfig.secretKey, variant: .sha1)
            let signCodeBuff = try hmac.authenticate(originalURL.bytes)
            let signCodeString = signCodeBuff.toBase64()?.replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_")
//            let signCodeString = signCodeBuff.toBase64()
            let token = accessKey + ":" + signCodeString!
            return token
        } catch {
            print("error signing")
        }
        return ""
    }

}
