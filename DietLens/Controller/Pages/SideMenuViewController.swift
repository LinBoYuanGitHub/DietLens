//
//  SideMenuViewController.swift
//  DietLens
//
//  Created by next on 31/10/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit
//import PBRevealViewController
import LGSideMenuController

class SideMenuViewController: LGSideMenuController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var sideMenuTable: UITableView!
    @IBOutlet weak var profileAvatar: RoundedImage!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var clickToEditLabel: UILabel!

    let labels: [String] = ["Home", "Food Diary", "Steps Counter", "Health Log", "Settings"]
    let iconNames: [String] = ["whiteHomeIcon", "whiteFoodDiaryIcon", "whiteStepCounterIcon", "healthCenterIcon", "whiteSettingIcon"]
    let storyboardIDs: [String] = ["DietLens", "FoodCalendarNavVC", "StepCounterVC", "healthCenterNavVC", "SettingsPage"]
    //used for mark sideMenu selection
    var currentSideMenuIndex  = 0

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.leftViewWidth = 100.0
//        self.leftViewPresentationStyle = .scaleFromLittle
        sideMenuTable.delegate = self
        sideMenuTable.dataSource = self
        //set nickname
        refreshUserName()
        loadAvatar()
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshUserName), name: .shouldRefreshSideBarHeader, object: nil)
    }

    func loadAvatar() {
        let preferences = UserDefaults.standard
        let facebookId = preferences.value(forKey: "facebookId")
        if facebookId != nil {
            let profileAvatarURL = URL(string: "https://graph.facebook.com/\(facebookId ?? "")/picture?type=normal")
            profileAvatar.kf.setImage(with: profileAvatarURL)
        }
    }

    @objc func refreshUserName() {
        let preferences = UserDefaults.standard
        let nicknameKey = "nickname"
        let nickname =  preferences.string(forKey: nicknameKey)
        if nickname != nil {
            userNameLabel.text = nickname
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        for subview in sideMenuTable.subviews where subview is UIVisualEffectView {
            subview.alpha = 0
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "menuButtonCell") as? SideMenuCell {
            if indexPath.row == currentSideMenuIndex {
                cell.setupSideMenuCell(buttonName: labels[indexPath.row], iconImage: UIImage(named: iconNames[indexPath.row])!, isSelected: true)
            } else {
                 cell.setupSideMenuCell(buttonName: labels[indexPath.row], iconImage: UIImage(named: iconNames[indexPath.row])!, isSelected: false)
            }
            //if indexPath.row == DataService.instance.screenUserIsIn {
               // cell.cellSelected()
            //}
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print ("item \(labels[indexPath.row]) was selected!")
        tableView.deselectRow(at: indexPath, animated: true)
//        self.revealViewController()!.revealLeftView()
        DataService.instance.screenUserIsIn = 0
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        var controller: UIViewController?
        // deselect food diary
        currentSideMenuIndex = indexPath.row
        // use notificationCenter to notify the homeVC to toggle menu
//        if labels[indexPath.row] == "Home"{
//            NotificationCenter.default.post(name: .toggleLeftView, object: nil)
//        } else {
//            controller = storyboard.instantiateViewController(withIdentifier: storyboardIDs[indexPath.row])
//            present(controller!, animated: true, completion: nil)
//        }
        let dataDict: [String: Int] = ["position": indexPath.row]
        NotificationCenter.default.post(name: .onSideMenuClick, object: nil, userInfo: dataDict)
        //reload the indicator position
        sideMenuTable.reloadData()
    }

    @IBAction func profileButtonPressed(_ sender: Any) {
        print("Go to profile page")
        let preferences = UserDefaults.standard
        let nicknameKey = "nickname"
        let nickname =  preferences.string(forKey: nicknameKey)
        if nickname == nil {
            performSegue(withIdentifier: "menuToLogin", sender: self)
        } else {
            performSegue(withIdentifier: "MenutoProfile", sender: self)
        }

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
