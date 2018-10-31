//
//  EmailLoginViewController.swift
//  DietLens
//
//  Created by linby on 2018/10/26.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import Reachability
import XLPagerTabStrip

class EmailLoginViewController: UIViewController {

    @IBOutlet weak var TFEmail: SkyFloatingLabelTextField!
    @IBOutlet weak var TFPassword: SkyFloatingLabelTextField!

    override func viewDidLoad() {
        TFEmail.delegate = self
        TFPassword.delegate = self
        TFEmail.keyboardType = .emailAddress
        TFEmail.clearButtonMode = .whileEditing
        setUpSkyFloatingLable()
        // Do any additional setup after loading the view.
        hideKeyboardWhenTappedAround()
    }

    func setUpSkyFloatingLable() {
        TFEmail.placeholder = "Email"
        TFEmail.font = UIFont(name: "PingFang SC-Light", size: 18)
        TFEmail.title = "Email"
        TFPassword.placeholder = "Password"
        TFPassword.font = UIFont(name: "PingFang SC-Light", size: 18)
        TFPassword.title = "at least 8 characters with letters"
        //delegate
        TFEmail.delegate = self
        TFPassword.delegate = self
    }

    @IBAction func onLoginBtnClicked(_ sender: Any) {

        if Reachability()!.connection == .none {
            AlertMessageHelper.showMessage(targetController: self, title: "", message: StringConstants.ErrMsg.noInternetErrorMsg)
            return
        }
        if (TFEmail.text?.isEmpty)! {
            TFEmail.errorMessage = "Please enter your email address"
            return
        } else if (TFPassword.text?.isEmpty)! {
            TFPassword.errorMessage = "Please enter your password"
            return
        } else if !TextValidtor.isValidEmail(testStr: TFEmail.text!) {
            TFEmail.errorMessage = "INVALID EMAIL"
            return
        }
        AlertMessageHelper.showLoadingDialog(targetController: self)
        //login request
        APIService.instance.loginRequest(userEmail: TFEmail.text!, password: TFPassword.text!, completion: { (isSuccess) in
            AlertMessageHelper.dismissLoadingDialog(targetController: self) {
                if isSuccess {
                    // save for basic authentication
                    let preferences = UserDefaults.standard
                    let pwdKey = PreferenceKey.passwordKey
                    preferences.setValue(self.TFPassword.text!, forKey: pwdKey)
                    //upload the device token to server
                    let fcmToken = preferences.string(forKey: PreferenceKey.fcmTokenKey)
                    let userId = preferences.string(forKey: PreferenceKey.userIdkey)
                    if userId != nil && fcmToken != nil {
                        APIService.instance.saveDeviceToken(uuid: userId!, fcmToken: fcmToken!, status: true, completion: { (flag) in
                            if flag {
                                print("send device token succeed")
                            }
                        })
                    }
                    DispatchQueue.main.async {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        if let controller = storyboard.instantiateViewController(withIdentifier: "HomeTabNVC")
                            as? UINavigationController {
                            //                            self.navigationController?.pushViewController(controller, animated: true)
                            self.present(controller, animated: true, completion: nil)
                        }
                    }
                } else {
                    AlertMessageHelper.showMessage(targetController: self, title: "", message: StringConstants.ErrMsg.loginErrMsg)
                    print("Login failed")
                }
            }
        }) { (errMsg) in
            AlertMessageHelper.dismissLoadingDialog(targetController: self)
            AlertMessageHelper.showMessage(targetController: self, title: "", message: errMsg)
        }
    }

    func keyboardWillShow() {
        if self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= (100)
        }
    }

    func keyboardWillHide() {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y += (100)
        }
    }

}

extension EmailLoginViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        keyboardWillShow()
        if textField == TFEmail {
            TFEmail.errorMessage = ""
        } else {
            TFPassword.errorMessage = ""
        }
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == TFEmail && !TextValidtor.isValidEmail(testStr: TFEmail.text!) {
            TFEmail.errorMessage = "INVALID EMAIL"
        } else {
            TFEmail.errorMessage = ""
        }
//        keyboardWillHide()
        return true
    }
}

extension EmailLoginViewController {

    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension EmailLoginViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "PASSWORD")
    }
}
