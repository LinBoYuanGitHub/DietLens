//
//  sideMenuContainerViewController.swift
//  DietLens
//
//  Created by linby on 2018/5/16.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
import LGSideMenuController

class SideMenuContainerViewController: LGSideMenuController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.navigationBar.barTintColor = UIColor(red: CGFloat(240.0/255.0), green: CGFloat(90.0/255.0), blue: CGFloat(90.0/255.0), alpha: 1.0)
    }
}
