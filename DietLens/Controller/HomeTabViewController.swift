//
//  HomeTabViewController.swift
//  DietLens
//
//  Created by linby on 2018/10/8.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class HomeTabViewController: UIViewController, UITabBarDelegate {

    @IBOutlet weak var homeTabBar: UITabBar!
    @IBOutlet weak var container: UIView!

    var tabViewControlers = [UIViewController]()
    let titles = ["Dietlens", "FoodDiary", "", "Health Log", "More"]

    var currentIndex = 0
    //refresh trigger flag
    var shouldSwitchToFoodDiary = false
    var shouldSwitchToMorePage = false
    var foodDiarySelectedDate = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
        homeTabBar.delegate = self
        if let tabItems = homeTabBar.items {
            for index in 0..<tabItems.count {
                tabItems[index].tag = index
            }
        }
        //intial child viewController
        let homeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DietLens")
        let foodDiaryVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FoodDiaryHistoryVC")
        //        let setpCounterVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StepCounterVC")
        let healthCenterVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "healthCenterVC")
        let moreVC =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MoreVC")
        initChildVC(targetController: homeVC)
        initChildVC(targetController: foodDiaryVC)
        //        initChildVC(targetController: setpCounterVC)
        tabViewControlers.append(UIViewController())
        initChildVC(targetController: healthCenterVC)
        initChildVC(targetController: moreVC)
        //add homeview as first SubView
        container.addSubview(tabViewControlers[currentIndex].view)
        tabViewControlers[currentIndex].didMove(toParentViewController: self)
        tabViewControlers[currentIndex].navigationController?.navigationBar.topItem?.title = titles[currentIndex]
        homeTabBar.selectedItem = homeTabBar.items?.first
        setNotificationRightNavigationButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //show markView for tap
        let preferences = UserDefaults.standard
        let shouldShowCoachMark = !preferences.bool(forKey: FirstTimeFlag.isNotFirstTimeViewHome)
        if shouldShowCoachMark {
            preferences.set(true, forKey: FirstTimeFlag.isNotFirstTimeViewHome)
        }
    }

    func initChildVC(targetController: UIViewController) {
        self.addChildViewController(targetController)
        targetController.view.frame = container.frame
        tabViewControlers.append(targetController)
    }

    override func viewWillAppear(_ animated: Bool) {
        //trigger to switch to foodDiary
        if shouldSwitchToFoodDiary {
            switchToFoodHistoryPage()
            shouldSwitchToFoodDiary = false
        } else if shouldSwitchToMorePage {
            switchToMorePage()
            shouldSwitchToMorePage = false
        }
    }

    func setNotificationRightNavigationButton() {
        let rightNavButton = UIBarButtonItem(image: UIImage(imageLiteralResourceName: "Notification"), style: .plain, target: self, action: #selector(toNotificationPage))
        rightNavButton.tintColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        self.navigationItem.rightBarButtonItem = rightNavButton
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }

    func setFoodDiaryRightNavigationButton() {
        let rightNavButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(switchToEditStatus))
        rightNavButton.tintColor = UIColor(red: 67/255, green: 67/255, blue: 67/255, alpha: 1)
        self.navigationItem.rightBarButtonItem = rightNavButton
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }

    func setSettingRightNavigationButton() {
        let rightNavButton = UIBarButtonItem(image: UIImage(imageLiteralResourceName: "SettingIcon_black"), style: .plain, target: self, action: #selector(toSettingPage))
        rightNavButton.tintColor = UIColor(red: 67/255, green: 67/255, blue: 67/255, alpha: 1)
        self.navigationItem.rightBarButtonItem = rightNavButton
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }

    @objc func switchToEditStatus() {
        if let targetVC = tabViewControlers[1] as? FoodDiaryHistoryViewController {
            targetVC.switchToEditStatus()
        }
    }

    @objc func toNotificationPage() {
        if !accountCheck() {
            return
        }
        if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "notificationListVC") as? NotificationsViewController {
            self.present(dest, animated: true, completion: nil)
        }
    }

    @objc func toSettingPage() {
        if !accountCheck() {
            return
        }
        if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsPage") as? SettingViewController {
            self.navigationController?.pushViewController(dest, animated: true)
        }
    }

    //func for switch to FoodDiary page
    func switchToFoodHistoryPage() {
        currentIndex = 1
        for view in container.subviews {
            view.removeFromSuperview()
        }
        if let foodHistoryVC = tabViewControlers[currentIndex] as? FoodDiaryHistoryViewController {
            //            foodHistoryVC.shouldRefreshDiary = true
            foodHistoryVC.selectedDate = foodDiarySelectedDate
        }
        homeTabBar.selectedItem = homeTabBar.items?[currentIndex]
        tabViewControlers[currentIndex].view.frame = container.frame
        container.addSubview(tabViewControlers[currentIndex].view)
        tabViewControlers[currentIndex].didMove(toParentViewController: self)
        tabViewControlers[currentIndex].navigationController?.navigationBar.topItem?.title = titles[currentIndex]
    }

    func switchToMorePage() {
        currentIndex = 4
        for view in container.subviews {
            view.removeFromSuperview()
        }
        homeTabBar.selectedItem = homeTabBar.items?[currentIndex]
        tabViewControlers[currentIndex].view.frame = container.frame
        container.addSubview(tabViewControlers[currentIndex].view)
        tabViewControlers[currentIndex].didMove(toParentViewController: self)
        tabViewControlers[currentIndex].navigationController?.navigationBar.topItem?.title = titles[currentIndex]
    }

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //change the top right navigation bar
        self.navigationController?.navigationBar.isHidden = true
        if item.tag == 0 {
            setNotificationRightNavigationButton()
        } else if item.tag == 1 {
            if !accountCheck() {
                return
            }
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            setFoodDiaryRightNavigationButton()
        } else if item.tag == 2 {
            if !accountCheck() {
                return
            }
            //set previousItem selected item
            homeTabBar.selectedItem = homeTabBar.items?[currentIndex]
            //camera View btn
            presentCamera()
            return
        } else if item.tag == 4 {
            setSettingRightNavigationButton()
        } else {
            if !accountCheck() {
                return
            }
            self.navigationItem.rightBarButtonItem = nil
        }
        //page switch
        currentIndex = item.tag
        for view in container.subviews {
            view.removeFromSuperview()
        }
        tabViewControlers[item.tag].view.frame = container.frame
        container.addSubview(tabViewControlers[item.tag].view)
        tabViewControlers[item.tag].didMove(toParentViewController: self)
        tabViewControlers[item.tag].navigationController?.navigationBar.topItem?.title = titles[item.tag]
    }

    func presentCamera() {
        if let dest = UIStoryboard(name: "AddFoodScreen", bundle: nil).instantiateInitialViewController() as? AddFoodViewController {
            if let navigator = self.navigationController {
                //clear controller to Bottom & add foodCalendar Controller
                let transition = CATransition()
                transition.duration = 0.3
                //                transition.type = kCATransitionFromTop
                transition.type = kCATransitionMoveIn
                transition.subtype = kCATransitionFromTop
                self.view.window?.layer.add(transition, forKey: kCATransition)
                navigator.pushViewController(dest, animated: false)
            }
        }
        //#google analytic log part
        Analytics.logEvent(StringConstants.FireBaseAnalytic.HomeClickCameraButton, parameters: nil)
    }
}

extension HomeTabViewController {

    //judge whether userId is Exist
    func accountCheck() -> Bool {
        let userId = UserDefaults.standard.string(forKey: PreferenceKey.userIdkey) ?? ""
        if userId.isEmpty { //redirect user to welcome page
            guard let welcomeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WelcomeVC") as? WelcomeViewController else {
                return false
            }
            welcomeVC.shouldShowNavBtn = true
            self.navigationController?.pushViewController(welcomeVC, animated: true)
            return false
        }
        return true
    }
}
