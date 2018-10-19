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
import SkyFloatingLabelTextField
import FBSDKLoginKit
import Reachability
import GoogleSignIn

struct FBProfileRequest: GraphRequestProtocol {
    typealias Response = GraphResponse

    var graphPath: String = "/me"
    var parameters: [String: Any]? = ["fields": "id, name, birthday, gender"]
    var accessToken: AccessToken? = .current
    var httpMethod: GraphRequestHTTPMethod = .GET
    var apiVersion: GraphAPIVersion = 2.7
}

class LoginViewController: UIViewController {

    @IBOutlet weak var TFEmail: SkyFloatingLabelTextField!
    @IBOutlet weak var TFPassword: SkyFloatingLabelTextField!
    @IBOutlet weak var facebookLoginBtn: UIButton!
    @IBOutlet weak var googleLoginBtn: UIButton!

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

    override func viewDidLoad() {
        super.viewDidLoad()
        TFEmail.delegate = self
        TFPassword.delegate = self
        TFEmail.keyboardType = .emailAddress
        setUpSkyFloatingLable()
        // Do any additional setup after loading the view.
        hideKeyboardWhenTappedAround()
//        facebookLoginBtn.delegate = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Back Arrow"), style: .plain, target: self, action: #selector(onBackPressed))
        self.navigationItem.leftBarButtonItem?.tintColor = .gray
        self.navigationItem.title = "Sign In"
    }

    @objc func onBackPressed() {
        self.navigationController?.popViewController(animated: true)
    }

    func setUpSkyFloatingLable() {
        TFEmail.placeholder = "Email"
        TFEmail.font = UIFont(name: "PingFang SC-Light", size: 16)
        TFEmail.title = "Email"
        TFPassword.placeholder = "Password"
        TFPassword.font = UIFont(name: "PingFang SC-Light", size: 16)
        TFPassword.title = "at least 8 characters with letters"
        //delegate
        TFEmail.delegate = self
        TFPassword.delegate = self
    }

    @IBAction func processFacebookLogin(_ sender: Any) {
        let loginManager = LoginManager(loginBehavior: .systemAccount, defaultAudience: .everyone)
        loginManager.loginBehavior = .native
        loginManager.logIn(readPermissions: [.publicProfile], viewController: self) { (loginResult) in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("user cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in!")
                let request = FBProfileRequest()
                request.start({ (_, result) in
                    switch result {
                    case .success(let response):
                        let facebookUserId = response.dictionaryValue!["id"]
                        let facebookUserName = response.dictionaryValue!["name"]
                        //validate FacebookId
                        AlertMessageHelper.showLoadingDialog(targetController: self)
                        guard let fbUserId = facebookUserId as? String else { return }
                        APIService.instance.facebookIdValidationRequest(accessToken: accessToken.authenticationToken, uuid: fbUserId, completion: { (isSuccess, isNewUser) in
                            AlertMessageHelper.dismissLoadingDialog(targetController: self)
                            if isSuccess {
                                //record userId & userName
                                let preferences = UserDefaults.standard
                                preferences.setValue(facebookUserId, forKey: "facebookId")
                                preferences.setValue(facebookUserName, forKey: "nickname")
                                if isNewUser {
                                    if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "navProfileVC") as? UINavigationController {
                                        var profile = UserProfile()
                                        if let name = facebookUserName as? String {
                                            profile.name = name
                                        }
                                        if let destVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegistrationProfileVC") as? RegistrationProfileViewController {
                                            destVC.profile = profile
                                            self.present(dest, animated: true, completion: nil)
                                        }
                                    }
                                } else {
                                    if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeTabNVC") as? UINavigationController {
                                        self.present(controller, animated: true, completion: nil)
                                    }
                                }
                            }
                        })
                        print("Graph Request Succeeded: \(response)")
                    case .failed(let error):
                        print("Graph Request Failed: \(error)")
                    }
                })
            }
        }
    }

    @IBAction func processGoogleLogin(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func forgetPwPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ForgetPwdVC")
        self.present(controller, animated: true, completion: nil)
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

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString str: String) -> Bool {
//        if let text = textField.text {
//            //Email validator
//            if textField == TFEmail {
//                let validationString = textField.text! + str
//                if text.count > 3 && !TextValidtor.isValidEmail(testStr: validationString) {
//                    TFEmail.errorMessage = "Invalid email"
//                } else {
//                    TFEmail.errorMessage = ""
//                }
//            }
//        }
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
        return true
    }

}

extension LoginViewController: FBSDKLoginButtonDelegate {

    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        } else if result.isCancelled {
            print("cancelled")
        } else {
            let request = FBProfileRequest()
            request.start({ (_, requestResult) in
                switch requestResult {
                case .success(let response):
                    let facebookUserId = response.dictionaryValue!["id"]
                    let facebookUserName = response.dictionaryValue!["name"]
                    //validate FacebookId
                    AlertMessageHelper.showLoadingDialog(targetController: self)
                    guard let fbUserId = facebookUserId as? String else { return }
                    APIService.instance.facebookIdValidationRequest(accessToken: result.token.tokenString, uuid: fbUserId, completion: { (isSuccess, isNewUser) in
                        AlertMessageHelper.dismissLoadingDialog(targetController: self)
                        if isSuccess {
                            //record userId & userName
                            let preferences = UserDefaults.standard
                            preferences.setValue(facebookUserId, forKey: PreferenceKey.facebookId)
                            preferences.setValue(facebookUserName, forKey: PreferenceKey.nickNameKey)
                            if isNewUser {
                                if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "navProfileVC") as? UINavigationController {
                                    var profile = UserProfile()
                                    if let name = facebookUserName as? String {
                                        profile.name = name
                                    }
                                    if let destVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegistrationProfileVC") as? RegistrationProfileViewController {
                                        destVC.profile = profile
                                        self.present(dest, animated: true, completion: nil)
                                    }
                                }
                            } else {
                                if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeTabNVC") as? UINavigationController {
                                    self.present(controller, animated: true, completion: nil)
                                }
                            }
                        }
                    })
                    print("Graph Request Succeeded: \(response)")
                case .failed(let error):
                    print("Graph Request Failed: \(error)")
                }
            })
        }
    }

    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {

    }

}

extension LoginViewController: GIDSignInDelegate, GIDSignInUIDelegate {

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            return
        }
//        AlertMessageHelper.showLoadingDialog(targetController: self)
        APIService.instance.googleIdValidationRequest(accessToken: user.authentication.idToken, uuid: user.userID, completion: { (isSuccess, isNewUser) in
            AlertMessageHelper.dismissLoadingDialog(targetController: self)
            if isSuccess {
                //record userId & userName
                let preferences = UserDefaults.standard
                preferences.setValue(user.userID, forKey: PreferenceKey.googleUserId)
                preferences.setValue(user.profile.name, forKey: PreferenceKey.nickNameKey)
                //tmp use
                if let avatarUrl = user.profile.imageURL(withDimension: 100).absoluteString as? String {
                    preferences.setValue(avatarUrl, forKey: PreferenceKey.googleImageUrl)
                }
                //tmp use
                if isNewUser {
                    if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "navProfileVC") as? UINavigationController {
                        var profile = UserProfile()
                        if let name = user.profile.name {
                            profile.name = name
                        }
                        if let avatarUrl = user.profile.imageURL(withDimension: 100).absoluteString as? String {
                            preferences.setValue(avatarUrl, forKey: PreferenceKey.googleImageUrl)
                        }
                        if let destVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegistrationProfileVC") as? RegistrationProfileViewController {
                            destVC.profile = profile
                            self.present(dest, animated: true, completion: nil)
                        }
                    }
                } else {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let controller = storyboard.instantiateViewController(withIdentifier: "HomeTabNVC") as? UINavigationController {
//                        self.navigationController?.pushViewController(controller, animated: true)
                        self.present(controller, animated: true, completion: nil)
                    }
                }
            }
        })
    }

    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }

    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
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
