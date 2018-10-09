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

class SettingViewController: UIViewController {
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    @IBAction func unwindToSettingPage(segue: UIStoryboardSegue) {}
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
        self.navigationController?.navigationBar.isHidden = false
        let textColor = UIColor(red: CGFloat(67/255), green: CGFloat(67/255), blue: CGFloat(67/255), alpha: 1.0)
        if let attributeGroup = [NSAttributedStringKey.foregroundColor: textColor, kCTFontAttributeName: UIFont(name: "PingFangSC-Regular", size: 18)!] as? [NSAttributedStringKey: Any] {
            self.navigationController?.navigationBar.titleTextAttributes = attributeGroup
        }
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
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
        let nicknameKey = "nickname"
        preferences.setValue(nil, forKey: nicknameKey)
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
