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

    var itemInfo: IndicatorInfo = "Description"

    init(itemInfo: IndicatorInfo) {
        self.itemInfo = itemInfo
        super.init(nibName: nil, bundle: nil)
    }
    required init(coder aDecoder: NSCoder!) { super.init(coder: aDecoder)!}
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationController?.navigationBar.isHidden = true
    }

    // MARK: - IndicatorInfoProvider

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }

}
