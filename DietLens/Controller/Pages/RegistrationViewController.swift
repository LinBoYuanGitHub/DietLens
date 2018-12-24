//
//  RegistrationViewController.swift
//  DietLens
//
//  Created by next on 7/11/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController {

    @IBOutlet weak var TFNickName: UITextField!
    @IBOutlet weak var TFRePassword: UITextField!
    @IBOutlet weak var TFEmail: UITextField!
    @IBOutlet weak var TFPassword: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        TFNickName.delegate = self
        TFRePassword.delegate = self
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

    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        //self.navigationController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func signUpButtonPressed(_ sender: Any) {
        if (TFNickName.text?.isEmpty)! {
            print("please fill in nick name")
            AlertMessageHelper.showMessage(targetController: self, title: "", message: "Please enter a nickname")
            return
        } else if (TFEmail.text?.isEmpty)! {
            print("please fill in email")
            AlertMessageHelper.showMessage(targetController: self, title: "", message: "Please enter your email address")
            return
        } else if (TFPassword.text?.isEmpty)! {
            print("please fill in password")
            AlertMessageHelper.showMessage(targetController: self, title: "", message: "Please enter your email address")
            return
        } else if TFRePassword.text != TFPassword.text {
            print("please confirm password again")
            AlertMessageHelper.showMessage(targetController: self, title: "", message: "please confirm password again")
            return
        } else {
            guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            appdelegate.showLoadingDialog()
            APIService.instance.register(email: TFEmail.text!, password: TFPassword.text!, completion: { (isSucceed) in
                appdelegate.dismissLoadingDialog()
                if isSucceed {
                    // save for basic authentication
                    let preferences = UserDefaults.standard
                    preferences.setValue(self.TFPassword.text!, forKey: PreferenceKey.passwordKey)
                    //to main page
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "sideLGMenuVC")
                    self.present(viewController, animated: true, completion: nil)
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
            }, failedCompletion: { (failedMsg) in
                AlertMessageHelper.dismissLoadingDialog(targetController: self) {
                    AlertMessageHelper.showMessage(targetController: self, title: "", message: failedMsg)
                }
            })
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? ProfileViewController {

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

    @IBAction func signInButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

}

extension RegistrationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == TFNickName {
            TFEmail.becomeFirstResponder()
            keyboardWillShow()
        } else if textField == TFEmail {
            TFPassword.becomeFirstResponder()
            keyboardWillShow()
        } else if textField == TFPassword {
            TFRePassword.becomeFirstResponder()
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

extension RegistrationViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
        keyboardWillHide()
    }
}
