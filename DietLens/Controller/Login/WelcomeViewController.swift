//
//  WelcomeViewController.swift
//  DietLens
//
//  Created by linby on 2018/9/7.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import GoogleSignIn

class WelcomeViewController: BaseViewController {

    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var facebookLoginBtn: UIButton!
    @IBOutlet weak var googleLoginBtn: UIButton!

    override func viewDidLoad() {

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationController?.navigationBar.isHidden = true
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func redirecToSignUpPage(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "RegistrationVC") as? RegistrationFirstStepViewController {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }

    @IBAction func redirecToSignInPage(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginViewController {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }

    @IBAction func processFacebookLogin(_ sender: UIButton) {
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
                                preferences.setValue(facebookUserId, forKey: PreferenceKey.facebookId)
                                preferences.setValue(facebookUserName, forKey: PreferenceKey.nickNameKey)
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
                                //is New User flow
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
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeTabNVC") as? UINavigationController {
//                                         self.navigationController?.pushViewController(controller, animated: true)
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

    @IBAction func processGoogleLogin(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }

}

extension WelcomeViewController: GIDSignInDelegate, GIDSignInUIDelegate {

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            return
        }

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
                    if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeTabNVC") as? UINavigationController {
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
