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
    @IBOutlet weak var dataTags: UILabel!

    let itemInfo: IndicatorInfo = "Description"
    var studyDesc = ""
    var dataTag = [DataTag]()

    override func viewDidLoad() {
        super.viewDidLoad()
        studyDescTextView.text = studyDesc
        var dataTagall: String = ""
        for entityi in dataTag {
            dataTagall += entityi.name + "\n"
        }
        dataTags.text = dataTagall
    }

    // MARK: - IndicatorInfoProvider

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }

}
