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
import LGSideMenuController

class WelcomeViewController: BaseViewController {

    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var facebookLoginBtn: UIButton!

    override func viewDidLoad() {

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
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
                                preferences.setValue(facebookUserId, forKey: "facebookId")
                                preferences.setValue(facebookUserName, forKey: "nickname")
                                if isNewUser {
                                    if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "navProfileVC") as? UINavigationController {
                                        var profile = UserProfile()
                                        if let name = facebookUserName as? String {
                                            profile.name = name
                                        }
                                        if let destVC = dest.viewControllers.first as? RegistrationSecondStepViewController {
                                            destVC.profile = profile
                                            self.present(dest, animated: true, completion: nil)
                                        }
                                    }
                                } else {
//                                    self.performSegue(withIdentifier: "loginToMainPage", sender: nil)
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    if let controller = storyboard.instantiateViewController(withIdentifier: "sideLGMenuVC") as? LGSideMenuController {
                                        self.navigationController?.pushViewController(controller, animated: true)
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

}
