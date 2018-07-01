//
//  RegistrationFirstStepViewController.swift
//  DietLens
//
//  Created by linby on 2018/6/28.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class RegistrationFirstStepViewController: UIViewController {
    //step one field
    @IBOutlet weak var TFuserName: UITextField!
    @IBOutlet weak var TFemail: UITextField!
    @IBOutlet weak var TFpassword: UITextField!
    @IBOutlet weak var TFconfirmPassword: UITextField!
    //step one btn
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var signInBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        TFuserName.delegate = self
        TFemail.delegate = self
        TFpassword.delegate = self
        TFconfirmPassword.delegate = self
        hideKeyboardWhenTappedAround()
    }

    @IBAction func signUp(_ sender: UIButton) {
        if (TFuserName.text?.isEmpty)! {
            print("please fill in nick name")
            AlertMessageHelper.showMessage(targetController: self, title: "", message: "Please enter a nickname")
            return
        } else if (TFemail.text?.isEmpty)! {
            print("please fill in email")
            AlertMessageHelper.showMessage(targetController: self, title: "", message: "Please enter your email address")
            return
        } else if (TFpassword.text?.isEmpty)! {
            print("please fill in password")
            AlertMessageHelper.showMessage(targetController: self, title: "", message: "Please enter your email address")
            return
        } else if TFconfirmPassword.text != TFpassword.text {
            print("please confirm password again")
            AlertMessageHelper.showMessage(targetController: self, title: "", message: "please confirm password again")
            return
        } else {
            AlertMessageHelper.showLoadingDialog(targetController: self)
            APIService.instance.register(nickName: TFuserName.text!, email: TFemail.text!, password: TFpassword.text!, completion: { (isSucceed) in
                AlertMessageHelper.dismissLoadingDialog(targetController: self) {
                    if isSucceed {
                        // save for basic authentication
                        let preferences = UserDefaults.standard
                        let pwdKey = "password"
                        preferences.setValue(self.TFpassword.text!, forKey: pwdKey)
                        //to main page
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = storyboard.instantiateViewController(withIdentifier: "sideLGMenuVC")
                        self.present(viewController, animated: true, completion: nil)
                        //save token to backend
                        let fcmToken = preferences.string(forKey: PreferenceKey.fcmTokenKey)
                        let userId = preferences.string(forKey: PreferenceKey.userIdkey)
                        if userId != nil && fcmToken != nil {
                            APIService.instance.saveDeviceToken(uuid: userId!, fcmToken: fcmToken!, status: "true", completion: { (flag) in
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
                    AlertMessageHelper.showMessage(targetController: self, title: "", message: failedMsg)
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

    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func toSignInPage(_ sender: UIButton) {
        //dismiss to sign in page
         dismiss(animated: true, completion: nil)
    }

    @IBAction func next(_ sender: UIButton) {
        //fill in data & jump to final
        if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegistrationVC2") as? RegistrationSecondStepViewController {
            self.navigationController?.pushViewController(dest, animated: true)
        }
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
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
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
