//
//  SettingViewController.swift
//  DietLens
//
//  Created by next on 6/11/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit
//import PBRevealViewController
import FacebookLogin
import GoogleSignIn

class SettingViewController: BaseViewController {
    @IBOutlet weak var albumSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        let preference = UserDefaults.standard
        let flag = preference.bool(forKey: PreferenceKey.saveToAlbumFlag)
        albumSwitch.setOn(flag, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //set rightBarButtonItem disapear
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }

    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func showAboutPage(_ sender: Any) {
        performSegue(withIdentifier: "toAboutPage", sender: nil)
    }

    @IBAction func showFeedBackPage(_ sender: Any) {
        performSegue(withIdentifier: "toFeedBackPage", sender: nil)
    }

    @IBAction func onSwitchValueChanged(_ sender: UISwitch) {
        let preference = UserDefaults.standard
        if sender.isOn {
            preference.set(true, forKey: PreferenceKey.saveToAlbumFlag)
        } else {
            preference.set(false, forKey: PreferenceKey.saveToAlbumFlag)
        }
    }

    @IBAction func logout(_ sender: Any) {
        AlertMessageHelper.showOkCancelDialog(targetController: self, title: "", message: "Confirm to logout?", postiveText: "Confirm", negativeText: "Cancel") { (iSuccess) in
            if iSuccess {
                APIService.instance.logOut(completion: { (_) in
                        //signOut no matter request succeed or not
                    DispatchQueue.main.async {
                        self.clearPersonalData()
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let controller = storyboard.instantiateViewController(withIdentifier: "WelcomeNVC")
                        self.present(controller, animated: true, completion: nil)
                    }
                })
            }
        }
    }

    func clearPersonalData() {
        let preferences = UserDefaults.standard
        preferences.setValue(nil, forKey: PreferenceKey.userIdkey)
        preferences.setValue(nil, forKey: PreferenceKey.facebookId)
        preferences.setValue(nil, forKey: PreferenceKey.googleUserId)
        preferences.setValue(nil, forKey: PreferenceKey.tokenKey)
        preferences.setValue(nil, forKey: PreferenceKey.nickNameKey)
        preferences.setValue(nil, forKey: PreferenceKey.googleUserId)
        preferences.setValue(nil, forKey: PreferenceKey.googleImageUrl)
        //google login
        GIDSignIn.sharedInstance().signOut()
        //facebook login
//        LoginManager().logOut()
    }

}
