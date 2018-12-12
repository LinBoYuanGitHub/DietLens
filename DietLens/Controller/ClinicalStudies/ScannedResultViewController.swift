//
//  ScannedResultViewController.swift
//  DietLens
//
//  Created by 马胖 on 12/12/18.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class ScannedResultViewController: ButtonBarPagerTabStripViewController {
    var isReload = false
    var studyEntity: ClinicalStudyEntity?

    override func viewDidLoad() {
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = .red
        settings.style.buttonBarItemFont = .systemFont(ofSize: 14)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        super.viewDidLoad()

    }
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {

        guard let descriptionVC = storyboard?.instantiateViewController(withIdentifier: "DescriptionViewController")
            as? DescriptionViewController, let eligibilityVC =
            storyboard?.instantiateViewController(withIdentifier: "EligibilityViewController") as? EligibilityViewController, let contactVC = storyboard?.instantiateViewController(withIdentifier: "ContactViewController")
                as? ContactViewController
            else { return [] }

        return [descriptionVC, eligibilityVC, contactVC]
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem  = UIBarButtonItem(image: UIImage(imageLiteralResourceName: "Back Arrow"), style: .plain, target: self, action: #selector(onBackPressed))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
        self.navigationItem.title = "Study"
        self.navigationItem.rightBarButtonItem  = UIBarButtonItem(title: "Join", style: .plain, target: self, action: #selector(onJoinPressed))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.black
    }

    @objc func onBackPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    @objc func onJoinPressed() {
        guard let scanresultVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EConsentViewController") as? EConsentViewController else {
            return
        }
        self.navigationController?.pushViewController(scanresultVC, animated: true)

    }

}
