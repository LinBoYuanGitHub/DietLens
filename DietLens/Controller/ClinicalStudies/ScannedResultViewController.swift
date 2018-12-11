//
//  ScannedResultViewController.swift
//  DietLens
//
//  Created by 马胖 on 10/12/18.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class ScannedResultViewController: ButtonBarPagerTabStripViewController {
    var isReload = false

    override func viewDidLoad() {
        // change selected bar color
        settings.style.buttonBarBackgroundColor = .clear
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = .red
        settings.style.buttonBarItemFont = UIFont.systemFont(ofSize: 14)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        print("viewdidload containerView:\(containerView)")
        super.viewDidLoad()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationItem.hidesBackButton = true
        print("viewwillAppear containerView:\(containerView)")
        self.navigationItem.leftBarButtonItem  = UIBarButtonItem(image: UIImage(imageLiteralResourceName: "Back Arrow"), style: .plain, target: self, action: #selector(onBackPressed))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
        self.navigationItem.title = "Study"
        self.navigationItem.rightBarButtonItem  = UIBarButtonItem(title: "Join", style: .plain, target: self, action: #selector(onJoin))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.black

//        //set height for bar
//        buttonBarView.selectedBar.frame.origin.y = buttonBarView.frame.size.height - 2.0
//        buttonBarView.selectedBar.frame.size.height = 2.0

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        print("viewDidAppear containerView:\(containerView)")
    }

    @objc func onBackPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    @objc func onJoin() {
        guard let eConsentVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EConsentViewController") as? EConsentViewController else {
            return
        }
        self.navigationController?.pushViewController(eConsentVC, animated: true)

    }

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        guard let child1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DescriptionViewController")as? DescriptionViewController else {
            return []
        }
        guard let child2 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EligibilityViewController")as? EligibilityViewController else {
            return []
        }
        guard let child3 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContactViewController")as? ContactViewController else {
            return []
        }

        guard isReload else {
            return [child1, child2, child3]
        }

        var childViewControllers =  [child1, child2, child3]
        for index in childViewControllers.indices {
            let nElements = childViewControllers.count - index
            let n = (Int(arc4random()) % nElements) + index
            if n != index {
                childViewControllers.swapAt(index, n)
            }
        }
        let nItems = 1 + (arc4random() % 8)
        return Array(childViewControllers.prefix(Int(nItems)))
    }

    override func reloadPagerTabStripView() {
        isReload = true
        if arc4random() % 2 == 0 {
            pagerBehaviour = .progressive(skipIntermediateViewControllers: arc4random() % 2 == 0, elasticIndicatorLimit: arc4random() % 2 == 0 )
        } else {
            pagerBehaviour = .common(skipIntermediateViewControllers: arc4random() % 2 == 0)
        }
        super.reloadPagerTabStripView()
    }
}
