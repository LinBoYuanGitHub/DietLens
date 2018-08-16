//
//  sideMainViewController.swift
//  DietLens
//
//  Created by linby on 2018/5/8.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
import LGSideMenuController

class SideMainViewController: LGSideMenuController {

    override func viewDidLoad() {
        let rootViewController = HomeViewController()
        let leftViewController = SideMenuViewController()
        let navigationController = UINavigationController(rootViewController: rootViewController)
        let sideMenuController = LGSideMenuController(rootViewController: navigationController,
                                                      leftViewController: leftViewController,
                                                      rightViewController: rightViewController)
        sideMenuController.leftViewWidth = 250.0
        sideMenuController.leftViewPresentationStyle = .scaleFromBig
    }

}
