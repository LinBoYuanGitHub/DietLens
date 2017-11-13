//
//  MainSlideMenuViewController.swift
//  DietLens
//
//  Created by next on 31/10/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit
import PBRevealViewController

class MainSlideMenuViewController: PBRevealViewController, PBRevealViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.leftViewRevealWidth = 250.0
        self.leftViewBlurEffectStyle = .extraLight
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func revealController(_ revealController: PBRevealViewController, shouldShowLeft viewController: UIViewController) -> Bool {
//        if viewController as? DiaryViewController != nil
//        {
//            return false
//        }
//        return true
//    }
    
    

}