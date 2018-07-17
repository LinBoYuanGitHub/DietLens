//
//  LoginViewController.swift
//  DietLens
//
//  Created by linby on 2018/7/2.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore

struct FBProfileRequest: GraphRequestProtocol {
    typealias Response = GraphResponse

    var graphPath: String = "/me"
    var parameters: [String: Any]? = ["fields": "id, name, birthday, gender"]
    var accessToken: AccessToken? = .current
    var httpMethod: GraphRequestHTTPMethod = .GET
    var apiVersion: GraphAPIVersion = 2.7
}

class LoginViewController: UIViewController {

    @IBOutlet weak var TFEmail: UITextField!
    @IBOutlet weak var TFPassword: UITextField!
    @IBOutlet weak var facebookLoginBtn: UIButton!

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
        //login request
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

    @IBAction func loginButtonClicked(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile], viewController: self) { (loginResult) in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("user cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                //TODO pass token & userId to server
                print("Logged in!")
                let request = FBProfileRequest()
                request.start({ (_, result) in
                    switch result {
                    case .success(let response):
                        let facebookUserId = response.dictionaryValue!["id"]
                        let facebookUserName = response.dictionaryValue!["name"]
                        let preferences = UserDefaults.standard
                        preferences.setValue(facebookUserId, forKey: "facebookId")
                        preferences.setValue(facebookUserName, forKey: "nickname")
                        var profile = UserProfile()
                        if let name = facebookUserName as? String {
                            profile.name = name
                        }
                        DispatchQueue.main.async {
//                            self.performSegue(withIdentifier: "loginToMainPage", sender: nil)
                            if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegistrationVC2") as? RegistrationSecondStepViewController {
                                dest.profile = profile
                                self.navigationController?.pushViewController(dest, animated: true)
                            }
                        }
                        print("Graph Request Succeeded: \(response)")
                    case .failed(let error):
                        print("Graph Request Failed: \(error)")
                    }
                })
            }
        }
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
