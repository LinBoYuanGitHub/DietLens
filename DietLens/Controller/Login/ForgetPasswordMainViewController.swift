//
//  ForgetPasswordMainViewController.swift
//  DietLens
//
//  Created by next on 26/2/18.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class ForgetPasswordMainViewController: UIViewController, UITextFieldDelegate {
    var emailToDisplay: String = ""
    @IBOutlet weak var emailAddrField: UITextField!
    @IBOutlet weak var pwdField: UITextField!
    @IBOutlet weak var cfmPwdField: UITextField!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailAddrField.text = emailToDisplay
        pwdField.delegate = self
        cfmPwdField.delegate = self
        pwdField.becomeFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == pwdField {
            textField.resignFirstResponder()
            cfmPwdField.becomeFirstResponder()
        }
        if textField == cfmPwdField {
            chngPwPressed(self)
        }
        return true
    }

    @IBAction func chngPwPressed(_ sender: Any) {
        // Jump to main page
        if let pwd = pwdField.text, !pwd.isEmpty {
            if let cfmPwd = cfmPwdField.text, !cfmPwd.isEmpty {
                if pwd == cfmPwd {
                    // TODO:Update backend server with new password
                    AlertMessageHelper.showLoadingDialog(targetController: self)
                    APIService.instance.resetChangePwRequest(userEmail: emailToDisplay, password: pwd, completion: { (succeeded) in
                        AlertMessageHelper.dismissLoadingDialog(targetController: self) {
                            if succeeded {
                                let alert = UIAlertController(title: "Successfully change password", message: "Signing you in now..", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Default action"), style: .`default`, handler: { _ in
                                    APIService.instance.loginRequest(userEmail: self.emailToDisplay, password: cfmPwd) { (isSuccess) in
                                        if isSuccess {
                                            // save for basic authentication
                                            let preferences = UserDefaults.standard
                                            let pwdKey = "password"
                                            preferences.setValue(cfmPwd, forKey: pwdKey)
                                            self.performSegue(withIdentifier: "loginToMainPage", sender: nil)
                                        } else {
                                            AlertMessageHelper.showMessage(targetController: self, title: "Error", message: "Change pw request failed")
                                        }
                                    }
                                }))
                                self.present(alert, animated: true, completion: nil)
                                AlertMessageHelper.showMessage(targetController: self, title: "Successfully change password", message: "Signing you in now..")
                            }
                        }
                    })

                } else {
                    alertWithTitle(title: "Error", message: "Both password fields do not match", viewController: self, toFocus: cfmPwdField)
                }
            } else {
                alertWithTitle(title: "Error", message: "Confirm password field is empty", viewController: self, toFocus: cfmPwdField)
            }
        } else {
            alertWithTitle(title: "Error", message: "Password field is empty", viewController: self, toFocus: pwdField)
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
