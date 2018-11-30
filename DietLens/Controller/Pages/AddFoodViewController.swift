//
//  AddFoodViewController.swift
//  DietLens
//
//  Created by louis on 11/11/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit
import Foundation
import XLPagerTabStrip
import CoreLocation

class AddFoodViewController: ButtonBarPagerTabStripViewController {

    var addFoodDate = Date()
    var mealType: String = StringConstants.MealString.breakfast
    var isSetMealByTimeRequired = true

    override public func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        guard let cameraViewController = storyboard?.instantiateViewController(withIdentifier: "cameraVC")
            as? CameraViewController, let textInputViewController =
            storyboard?.instantiateViewController(withIdentifier: "textInputVC") as? TextInputViewController
            else { return [] }
        //passing value to child VC
        cameraViewController.addFoodDate = addFoodDate
        cameraViewController.mealType = mealType
        cameraViewController.isSetMealByTimeRequired = isSetMealByTimeRequired
        textInputViewController.addFoodDate = addFoodDate
        textInputViewController.mealType = mealType
        textInputViewController.isSetMealByTimeRequired = isSetMealByTimeRequired
        return [cameraViewController, textInputViewController]
    }

    override func viewWillAppear(_ animated: Bool) {
        //set status bar appearance
        UIApplication.shared.statusBarStyle = .lightContent
        self.containerView.isScrollEnabled = false
        self.navigationController?.navigationBar.isHidden = true
        if currentIndex == 0 {
            if let cameraVC =  self.viewControllers.first as? CameraViewController {
                cameraVC.viewWillAppear(false)
            }
        } else {
            if let textInputVC = self.viewControllers[1] as? TextInputViewController {
                textInputVC.viewWillAppear(false)
            }
        }
    }

    override func viewDidLoad() {
        //hid navaigation bar
        self.navigationController?.navigationBar.isHidden = true
        // change selected bar color
        settings.style.buttonBarBackgroundColor = .clear
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = .white
        settings.style.buttonBarItemFont = UIFont(name: "PingFang SC", size: 16)!
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .white
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0

        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
        }
        super.viewDidLoad()
        containerView.bounces = false
        containerView.alwaysBounceHorizontal = false
        containerView.scrollsToTop = false
        //create a new foodDiary object
        FoodDiaryDataManager.instance.foodDiaryEntity = FoodDiaryEntity()
    }

    override func viewDidAppear(_ animated: Bool) {
        //set height for bar
        buttonBarView.selectedBar.frame.origin.y = buttonBarView.frame.size.height - 2.0
        buttonBarView.selectedBar.frame.size.height = 2.0
    }

    @IBAction func cancelAddFood(_ sender: UIButton) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionReveal
        transition.subtype = kCATransitionFromBottom
        self.view.window?.layer.add(transition, forKey: kCATransition)
        self.navigationController?.popViewController(animated: false)
    }
}
