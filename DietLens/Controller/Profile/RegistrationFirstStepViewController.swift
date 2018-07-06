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
    }

    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
        //navigation controller
        self.navigationController?.navigationBar.isHidden = false
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Back Arrow"), style: .plain, target: self, action: #selector(onBackPressed))
        let textColor = UIColor(red: CGFloat(67/255), green: CGFloat(67/255), blue: CGFloat(67/255), alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: textColor, kCTFontAttributeName: UIFont(name: "PingFangSC-Regular", size: 18)!] as! [NSAttributedStringKey: Any]
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }

    @objc func onBackPressed() {
        self.dismiss(animated: true, completion: nil)
    }

    func checkEmail(email: String) {
        //return if email is empty
        if email.isEmpty {
            return
        }
        APIService.instance.emailValidationRequest(userEmail: email, completion: { (isSuccess) in
            self.redTick.isHidden = !isSuccess
            self.emailCheckerLabel.isHidden = isSuccess
        }) { (errMessage) in
            self.emailCheckerLabel.alpha = 1
            self.emailCheckerLabel.text = errMessage
            self.redTick.isHidden = true
        }
    }

    @IBAction func signUp(_ sender: UIButton) {
        if (TFuserName.text?.isEmpty)! {
            print("please fill in nick name")
            errMsgLabel.text = "Please enter a nickname"
            return
        } else if (TFemail.text?.isEmpty)! {
            print("please fill in email")
            errMsgLabel.text = "please fill in email"
            return
        } else if (TFpassword.text?.isEmpty)! {
            print("please fill in password")
            errMsgLabel.text = "please fill in password"
            return
        } else if TFconfirmPassword.text != TFpassword.text {
            print("please confirm password again")
            errMsgLabel.text = "please confirm password again"
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
                        //set up profile
                        self.profile.name = self.TFuserName.text!
                        self.profile.email = self.TFemail.text!
                        //to main page
//                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                        let viewController = storyboard.instantiateViewController(withIdentifier: "sideLGMenuVC")
//                        self.present(viewController, animated: true, completion: nil)
                        //to registration VC2 page
                        if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegistrationVC2") as? RegistrationSecondStepViewController {
                            dest.profile = self.profile
                            self.navigationController?.pushViewController(dest, animated: true)
                        }
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

    @IBAction func toSignInPage(_ sender: UIButton) {
        //dismiss to sign in page
         dismiss(animated: true, completion: nil)
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
