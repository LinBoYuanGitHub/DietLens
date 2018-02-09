//
//  AlertMessageHelper.swift
//  DietLens
//
//  Created by linby on 27/12/2017.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation
import UIKit
class AlertMessageHelper {

    class func showMessage(targetController: UIViewController, title: String, message: String) {
        showMessage(targetController: targetController, title: title, message: message, confirmText: "OK")
    }

    class func showMessage(targetController: UIViewController, title: String, message: String, confirmText: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString(confirmText, comment: "Default action"), style: .`default`, handler: { _ in
            //can add completion for call back
        }))
        targetController.present(alert, animated: true, completion: nil)
    }

    class func showOkCancelDialog(targetController: UIViewController, title: String, message: String, postiveText: String, negativeText: String, callback: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString(postiveText, comment: "Default action"), style: .`default`, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
            callback(true)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString(negativeText, comment: "Default action"), style: .cancel, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
            callback(false)
        }))
        targetController.present(alert, animated: true, completion: nil)
    }
}
