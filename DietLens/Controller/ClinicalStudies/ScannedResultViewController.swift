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
        super.viewDidLoad()

        buttonBarView.selectedBar.backgroundColor = UIColor.red
        buttonBarView.backgroundColor = UIColor.white
        buttonBarView.frame = CGRect(x: 0, y: 90, width: UIScreen.main.bounds.width, height: 45)
        buttonBarView.selectedBar.tintColor = UIColor.red  //????why it doesnot work

        settings.style.buttonBarItemBackgroundColor = UIColor.white
        settings.style.buttonBarItemTitleColor = UIColor.black
        settings.style.buttonBarItemFont = UIFont.systemFont(ofSize: 14)

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem  = UIBarButtonItem(image: UIImage(imageLiteralResourceName: "Back Arrow"), style: .plain, target: self, action: #selector(onBackPressed))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
        self.navigationItem.title = "Scan Result"

    }

    @objc func onBackPressed() {
        self.navigationController?.popViewController(animated: true)
    }

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DescriptionViewController")as? DescriptionViewController
        let child2 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EligibilityViewController")as? EligibilityViewController
        let child3 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContactViewController")as? ContactViewController

        guard isReload else {
            return [child1!, child2!, child3!]
        }

        var childViewControllers =  [child1!, child2!, child3!]
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
