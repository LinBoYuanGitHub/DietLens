//
//  AddFoodViewController.swift
//  DietLens
//
//  Created by louis on 11/11/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation
import XLPagerTabStrip

class AddFoodViewController: ButtonBarPagerTabStripViewController {
    var addFoodDate = Date()
    var mealType: Meal = .dinner
    var isSetMealByTimeRequired = true

    override public func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        guard let cameraViewController = storyboard?.instantiateViewController(withIdentifier: "cameraVC")
            as? CameraViewController, let textInputViewController =
            storyboard?.instantiateViewController(withIdentifier: "textInputVC") as? TextInputViewController
            else { return [] }

        return [cameraViewController, textInputViewController]
    }

    override func viewWillAppear(_ animated: Bool) {
        self.containerView.isScrollEnabled = false
        self.navigationController?.navigationBar.isHidden = true
        self.sideMenuController?.isLeftViewSwipeGestureEnabled = false
    }

    override func viewDidLoad() {
        //hid navaigation bar
        self.navigationController?.navigationBar.isHidden = true
        // change selected bar color
        settings.style.buttonBarBackgroundColor = .clear
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = .white
        settings.style.buttonBarItemFont = UIFont(name: "PingFang SC", size: 14)!
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .white
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0

        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
//            oldCell?.label.textColor = .white
//            newCell?.label.textColor = UIColor(red: 0.29, green: 0.56, blue: 0.89, alpha: 1.0)
        }

        super.viewDidLoad()
        containerView.bounces = false
        containerView.alwaysBounceHorizontal = false
        containerView.scrollsToTop = false
//        NotificationCenter.default.addObserver(self, selector: #selector(onNotifyToDismiss), name: .addDiaryDismiss, object: nil)
    }

    @IBAction func cancelAddFood(_ sender: UIButton) {
            self.navigationController?.popViewController(animated: true)
//        dismiss(animated: true, completion: nil)
    }
}
