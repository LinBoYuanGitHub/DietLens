//
//  HomeTabViewController.swift
//  DietLens
//
//  Created by linby on 2018/10/8.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class HomeTabViewController: UIViewController, UITabBarDelegate {

    @IBOutlet weak var homeTabBar: UITabBar!
    @IBOutlet weak var container: UIView!

    var tabViewControlers = [UIViewController]()
    let titles = ["Dietlens", "FoodDiary", "", "Health Log", "More"]

    var currentIndex = 0
    //refresh trigger flag
    var shouldSwitchToFoodDiary = false

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
        let setpCounterVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StepCounterVC")
        let healthCenterVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "healthCenterVC")
        let moreVC =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsPage")
        initChildVC(targetController: homeVC)
        initChildVC(targetController: foodDiaryVC)
        initChildVC(targetController: setpCounterVC)
        initChildVC(targetController: healthCenterVC)
        initChildVC(targetController: moreVC)
        //add homeview as first SubView
        container.addSubview(tabViewControlers[currentIndex].view)
        tabViewControlers[currentIndex].didMove(toParentViewController: self)
        tabViewControlers[currentIndex].navigationController?.navigationBar.topItem?.title = titles[currentIndex]
        homeTabBar.selectedItem = homeTabBar.items?.first
    }

    func initChildVC(targetController: UIViewController) {
        self.addChildViewController(targetController)
        targetController.view.frame = container.frame
        tabViewControlers.append(targetController)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
//        self.navigationItem.hidesBackButton = true
        //trigger to switch to foodDiary
        if shouldSwitchToFoodDiary {
            switchToFoodHistoryPage()
            shouldSwitchToFoodDiary = false
        }
    }

    //func for switch to FoodDiary page
    func switchToFoodHistoryPage() {
        currentIndex = 1
        for view in container.subviews {
            view.removeFromSuperview()
        }
        if let foodHistoryVC = tabViewControlers[currentIndex] as? FoodDiaryHistoryViewController {
            foodHistoryVC.shouldRefreshDiary = true
        }
        homeTabBar.selectedItem = homeTabBar.items?[currentIndex]
        tabViewControlers[currentIndex].view.frame = container.frame
        container.addSubview(tabViewControlers[currentIndex].view)
        tabViewControlers[currentIndex].didMove(toParentViewController: self)
        tabViewControlers[currentIndex].navigationController?.navigationBar.topItem?.title = titles[currentIndex]

    }

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag == 2 {
            //set previousItem selected item
            homeTabBar.selectedItem = homeTabBar.items?[currentIndex]
            //camera View btn
            presentCamera()
            return
        }
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
                //                self.navigationController?.view.layer.add(transition, forKey: kCATransition)
                navigator.pushViewController(dest, animated: false)
            }
        }
    }
}
