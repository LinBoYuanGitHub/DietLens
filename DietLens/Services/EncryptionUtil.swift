//
//  EncryptionUtil.swift
//  DietLens
//
//  Created by linby on 27/04/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import Foundation
import CryptoSwift

class EncryptionUtil{
    
    public static func generateQiniuDownloadURL(originalURL:String){
        do{
            let hmac = try HMAC(key: QiniuConfig.secretKey, variant: .sha1)
            let signCodeBuff = try hmac.authenticate(originalURL.bytes)
            let signCodeString = String(bytes: signCodeBuff, encoding: .utf8)
        }catch{
            
        }
    }
    
}
