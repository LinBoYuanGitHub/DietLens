//
//  DescriptionViewController.swift
//  DietLens
//
//  Created by 马胖 on 10/12/18.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class DescriptionViewController: UIViewController, IndicatorInfoProvider {

    @IBOutlet weak var studyDescTextView: UITextView!

    let itemInfo: IndicatorInfo = "Description"
    var studyDesc = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        studyDescTextView.text = studyDesc
//        self.navigationController?.navigationBar.isHidden = true
    }

    // MARK: - IndicatorInfoProvider

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }

}
