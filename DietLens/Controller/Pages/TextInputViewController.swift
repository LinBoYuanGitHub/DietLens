//
//  TextInputViewController.swift
//  DietLens
//
//  Created by louis on 11/11/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation
import UIKit
import XLPagerTabStrip

class TextInputViewController: UIViewController, IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "BY TEXT")
    }
}
