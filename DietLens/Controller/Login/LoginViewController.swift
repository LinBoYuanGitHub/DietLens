//
//  LoginViewController.swift
//  DietLens
//
//  Created by linby on 2018/7/2.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var TFEmail: UITextField!
    @IBOutlet weak var TFPassword: UITextField!

    @IBAction func unwindToMainPage(segue: UIStoryboardSegue) {}

    @IBAction func onLoginBtnClicked(_ sender: Any) {
        if (TFEmail.text?.isEmpty)! {
            AlertMessageHelper.showMessage(targetController: self, title: "", message: " Please enter your email address")
            return
        } else if (TFPassword.text?.isEmpty)! {
            AlertMessageHelper.showMessage(targetController: self, title: "", message: "Please enter your password")
            return
        }
        AlertMessageHelper.showLoadingDialog(targetController: self)
        APIService.instance.loginRequest(userEmail: TFEmail.text!, password: TFPassword.text!) { (isSuccess) in
            AlertMessageHelper.dismissLoadingDialog(targetController: self) {
                if isSuccess {
                    // save for basic authentication
                    let preferences = UserDefaults.standard
                    let pwdKey = "password"
                    preferences.setValue(self.TFPassword.text!, forKey: pwdKey)
                    //upload the device token to server
                    let fcmToken = preferences.string(forKey: PreferenceKey.fcmTokenKey)
                    let userId = preferences.string(forKey: PreferenceKey.userIdkey)
                    if userId != nil && fcmToken != nil {
                        APIService.instance.saveDeviceToken(uuid: userId!, fcmToken: fcmToken!, status: "true", completion: { (flag) in
                            if flag {
                                print("send device token succeed")
                            }
                        })
                    }
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "loginToMainPage", sender: nil)
                    }
                } else {
                    AlertMessageHelper.showMessage(targetController: self, title: "", message: "Login failed")
                    print("Login failed")
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        TFEmail.delegate = self
        TFPassword.delegate = self
        TFEmail.keyboardType = .emailAddress
        // Do any additional setup after loading the view.
        hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func forgetPwPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "GoToForgetPwEmail", sender: self)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let emailTyped = TFEmail.text, !emailTyped.isEmpty {
            if segue.identifier == "GoToForgetPwEmail"{
                if let emailConfirm = segue.destination as? ForgetPasswordEmailViewController {
                    emailConfirm.emailFromLogin = emailTyped
                }
            }
        }

        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}

extension LoginViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}

extension LoginViewController {

    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
