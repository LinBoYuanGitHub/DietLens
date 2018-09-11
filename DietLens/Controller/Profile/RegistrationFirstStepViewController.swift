//
//  RegistrationFirstStepViewController.swift
//  DietLens
//
//  Created by linby on 2018/6/28.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import Reachability

class RegistrationFirstStepViewController: UIViewController {
    //step one field
    @IBOutlet weak var TFuserName: SkyFloatingLabelTextField!
    @IBOutlet weak var TFemail: SkyFloatingLabelTextField!
    @IBOutlet weak var TFpassword: SkyFloatingLabelTextField!
    @IBOutlet weak var TFconfirmPassword: SkyFloatingLabelTextField!
    //step one btn
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var signInBtn: UIButton!
    //text reminder
    @IBOutlet weak var emailCheckerLabel: UILabel!
    @IBOutlet weak var errMsgLabel: UILabel!
    @IBOutlet weak var redTick: UIImageView!
    //user profile
    var profile = UserProfile()

    override func viewDidLoad() {
        super.viewDidLoad()
        TFuserName.delegate = self
        TFemail.delegate = self
        TFpassword.delegate = self
        TFconfirmPassword.delegate = self
        hideKeyboardWhenTappedAround()
        setUpSkyFloatingLabel()
    }

    func setUpSkyFloatingLabel() {
        //username
        TFuserName.placeholder = "Nickname"
        TFuserName.font = UIFont(name: "PingFang SC-Light", size: 16)
        TFuserName.title = "Nickname"
        //email
        TFemail.placeholder = "Email"
        TFemail.font = UIFont(name: "PingFang SC-Light", size: 16)
        TFemail.title = "Email"
        //password
        TFpassword.placeholder = "Password"
        TFpassword.font = UIFont(name: "PingFang SC-Light", size: 16)
        TFpassword.title = "at least 8 characters with letters"
        //confirm password
        TFconfirmPassword.placeholder = "Confirm password"
        TFconfirmPassword.font = UIFont(name: "PingFang SC-Light", size: 16)
        TFconfirmPassword.title = "confirm password"
    }

    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
        //navigation controller
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Back Arrow"), style: .plain, target: self, action: #selector(onBackPressed))
        self.navigationItem.leftBarButtonItem?.tintColor = .gray
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(onDonePressed))
        self.navigationItem.rightBarButtonItem?.tintColor = .gray
        self.navigationItem.title = "Sign Up"
        let textColor = UIColor(red: CGFloat(67/255), green: CGFloat(67/255), blue: CGFloat(67/255), alpha: 1.0)
        if let attributeGroup = [NSAttributedStringKey.foregroundColor: textColor, kCTFontAttributeName: UIFont(name: "PingFangSC-Regular", size: 18)!] as?  [NSAttributedStringKey: Any] {
            self.navigationController?.navigationBar.titleTextAttributes = attributeGroup
        }
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }

    @objc func onBackPressed() {
//        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }

    @objc func onDonePressed() {
        signUpFunction()
    }

    func checkEmail(email: String) {
        //return if email is empty
        if email.isEmpty {
            return
        }
        APIService.instance.emailValidationRequest(userEmail: email, completion: { (isSuccess) in
            self.redTick.isHidden = !isSuccess
//            self.emailCheckerLabel.isHidden = isSuccess
        }) { (errMessage) in
//            self.emailCheckerLabel.alpha = 1
//            self.emailCheckerLabel.text = errMessage
            self.TFemail.errorMessage = errMessage
            self.redTick.isHidden = true
        }
    }

    func showErrMsg(errMsg: String) {
        errMsgLabel.isHidden = false
        errMsgLabel.text = errMsg
        errMsgLabel.alpha = 1
    }

    @IBAction func signUp(_ sender: UIButton) {
        //internet connection
        signUpFunction()
    }

    func signUpFunction() {
        if Reachability()!.connection == .none {
            AlertMessageHelper.showMessage(targetController: self, title: "", message: StringConstants.ErrMsg.loginErrMsg)
            return
        } else if (TFuserName.text?.isEmpty)! {
            TFuserName.errorMessage = "Please enter a nickname"
            //            showErrMsg(errMsg: "Please enter a nickname")
            return
        } else if (TFemail.text?.isEmpty)! {
            TFemail.errorMessage = "Please enter your email address"
            //            showErrMsg(errMsg: "Please enter your email address")
            return
        } else if (TFpassword.text?.isEmpty)! {
            TFpassword.errorMessage = "Please fill in your password"
            //            showErrMsg(errMsg: "Please fill in your password")
            return
        } else if TFconfirmPassword.text != TFpassword.text {
            TFconfirmPassword.errorMessage = "Verify password failed"
            //            showErrMsg(errMsg: "Verify password failed")
            return
        } else {
            AlertMessageHelper.showLoadingDialog(targetController: self)
            APIService.instance.register(nickName: TFuserName.text!, email: TFemail.text!, password: TFpassword.text!, completion: { (isSucceed) in
                AlertMessageHelper.dismissLoadingDialog(targetController: self) {
                    if isSucceed {
                        // save for basic authentication
                        let preferences = UserDefaults.standard
                        preferences.setValue(self.TFpassword.text!, forKey: PreferenceKey.passwordKey)
                        //set up profile
                        self.profile.name = self.TFuserName.text!
                        self.profile.email = self.TFemail.text!
                        //to registration VC2 page
                        if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegistrationVC2") as? RegistrationSecondStepViewController {
                            dest.profile = self.profile
                            self.navigationController?.pushViewController(dest, animated: true)
                        }
                        //save token to backend
                        let fcmToken = preferences.string(forKey: PreferenceKey.fcmTokenKey)
                        let userId = preferences.string(forKey: PreferenceKey.userIdkey)
                        if userId != nil && fcmToken != nil {
                            APIService.instance.saveDeviceToken(uuid: userId!, fcmToken: fcmToken!, status: true, completion: { (flag) in
                                if flag {
                                    print("send device token succeed")
                                }
                            })
                        }
                    } else {
                        print("register failed")
                        AlertMessageHelper.showMessage(targetController: self, title: "", message: "Registration fail")
                    }
                }
            }, failedCompletion: { (failedMsg) in
                AlertMessageHelper.dismissLoadingDialog(targetController: self) {
                    self.showErrMsg(errMsg: failedMsg)
                    //                    AlertMessageHelper.showMessage(targetController: self, title: "", message: failedMsg)
                }
            })
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

    @IBAction func toSignInPage(_ sender: UIButton) {
        //dismiss to sign in page
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LoginVC")
        self.present(controller, animated: true, completion: nil)
    }

}

extension RegistrationFirstStepViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == TFuserName {
            TFemail.becomeFirstResponder()
            keyboardWillShow()
        } else if textField == TFemail {
            TFpassword.becomeFirstResponder()
            keyboardWillShow()
        } else if textField == TFpassword {
            TFconfirmPassword.becomeFirstResponder()
            keyboardWillShow()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        keyboardWillShow()
        TFuserName.errorMessage = ""
        TFemail.errorMessage = ""
        TFpassword.errorMessage = ""
        TFconfirmPassword.errorMessage = ""
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == TFemail {
            checkEmail(email: TFemail.text!)
        }
        keyboardWillHide()
        return true
    }

}

extension RegistrationFirstStepViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
