//
//  ForgetPasswordEmailViewController.swift
//  DietLens
//
//  Created by next on 26/2/18.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class ForgetPasswordEmailViewController: UIViewController, UITextFieldDelegate {
    var emailFromLogin: String = ""
    @IBOutlet weak var emailAddr: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        emailAddr.delegate = self
        emailAddr.keyboardType = .emailAddress
        hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if emailFromLogin != "" {
            emailAddr.text = emailFromLogin
        } /*else {
         emailAddr.becomeFirstResponder()
         }*/

    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailAddr {
            cfmEmailPressed(self)
        }
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func closeBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func cfmEmailPressed(_ sender: Any) {
        if let emailAddrText = emailAddr.text, !emailAddrText.isEmpty {
            // call backend server
            guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            appdelegate.showLoadingDialog()
            APIService.instance.resetPwRequest(userEmail: emailAddrText) { (isSuccess) in
                if isSuccess {
                    appdelegate.dismissLoadingDialog()
                    AlertMessageHelper.showOkCancelDialog(targetController: self, title: "", message: "reset password email has already been sent", postiveText: "confirm", negativeText: "cancel", callback: { (isPositive) in
                        if isPositive {
                            self.dismiss(animated: true, completion: nil)
                        } else {
                            self.dismiss(animated: true, completion: nil)
                        }
                    })
                } else {
                    AlertMessageHelper.dismissLoadingDialog(targetController: self) {
                        self.alertWithTitle(title: "Error", message: "No such email found!", viewController: self, toFocus: self.emailAddr)
                    }
                }
            }
            // With 2FA
            //self.performSegue(withIdentifier: "GoToForgetVerify", sender: nil)
            // Without 2FA
            //self.performSegue(withIdentifier: "GoToForgetPwMain", sender: nil)
        } else {
            alertWithTitle(title: "Error", message: "Please fill in your email", viewController: self, toFocus: self.emailAddr)
        }
    }

    func alertWithTitle(title: String!, message: String, viewController: UIViewController, toFocus: UITextField) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: {_ in
            toFocus.becomeFirstResponder()
        })
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }

}

extension ForgetPasswordEmailViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
