//
//  SettingViewController.swift
//  DietLens
//
//  Created by next on 6/11/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit
import PBRevealViewController

class SettingViewController: UIViewController {
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    @IBAction func unwindToSettingPage(segue: UIStoryboardSegue) {}
    override func viewDidLoad() {
        super.viewDidLoad()

//        UINavigationBar.appearance().titleTextAttributes = [
//            NSAttributedStringKey.font: UIFont(name: "SignPainterHouseScript", size: 32)!, NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.4509400725, green: 0.4510070682, blue: 0.4509189129, alpha: 1)]
//        let navigationBar = UINavigationBar.appearance()
//        navigationBar.barTintColor = #colorLiteral(red: 0.9724672437, green: 0.9726032615, blue: 0.9724243283, alpha: 1)
//        navigationBar.isTranslucent = false
//        navigationBar.setBackgroundImage(UIImage(), for: .default)
//        navigationBar.shadowImage = UIImage()
//        navigationBarItem.backBarButtonItem = nil

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func logout(_ sender: Any) {
        let preferences = UserDefaults.standard
        let key = "userId"
        let userId = preferences.string(forKey: key)
        if userId == nil {
            //no userId cannot Logout
            return
        }
        //request new userId
        APIService.instance.getUUIDRequest { (userID) in
            preferences.setValue(userID, forKey: key)
            let didSave = preferences.synchronize()
            if !didSave {
                print("Couldn`t save,fatal exception happened")
            } else {
                DispatchQueue.main.async {
                    self.clearPersonalData()
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "MainViewController")
                    self.present(controller, animated: true, completion: nil)
                }
            }
        }
    }

    func clearPersonalData() {
        let preferences = UserDefaults.standard
        let nicknameKey = "nickname"
        preferences.setValue(nil, forKey: nicknameKey)
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
