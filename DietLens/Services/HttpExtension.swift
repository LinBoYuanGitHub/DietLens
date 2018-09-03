//
//  HttpExtension.swift
//  DietLens
//
//  Created by linby on 2018/8/29.
//  Copyright © 2018 NExT++. All rights reserved.
//

import Foundation
import UIKit

extension APIService {

    func onRedirectToAppStore() {
       redirectToTargetURL(urlString: RedirectAddress.AppStoreURL)
    }

    func onRedirectToWebPage() {
        //show dialog then redirect to browser
        redirectToTargetURL(urlString: RedirectAddress.DietLensURL)
    }

    func redirectToTargetURL(urlString: String) {
        let url  = NSURL(string: urlString)
        if let appURL = url as URL? {
            if UIApplication.shared.canOpenURL(appURL) == true {
                UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
            }
        }
    }

}
