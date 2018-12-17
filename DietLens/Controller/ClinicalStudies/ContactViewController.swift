//
//  ContactViewController.swift
//  DietLens
//
//  Created by 马胖 on 10/12/18.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class ContactViewController: UIViewController, IndicatorInfoProvider {

    var itemInfo: IndicatorInfo = "Contact"
    @IBOutlet weak var contactorLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var organizationLabel: UILabel!

    var contactorText: String = ""
    var phoneText: String = ""
    var organizationText: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        contactorLabel.text = contactorText
        phoneLabel.text = phoneText
        organizationLabel.text = organizationText

    }

    // MARK: - IndicatorInfoProvider

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }

}
