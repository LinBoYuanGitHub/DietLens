//
//  ScanResultViewController.swift
//  DietLens
//
//  Created by 马胖 on 6/12/18.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
import Foundation
import XLPagerTabStrip
import CoreLocation
import FirebaseAnalytics

class ScanResultViewController: BaseViewController {

    @IBOutlet weak var scanResultTabBer: UITabBar!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var scanResultScrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var eligibilityView: UIView!
    @IBOutlet weak var contactView: UIView!
    @IBOutlet weak var tabBarLine: UILabel!

    @IBOutlet weak var descriptionbtn: UITabBarItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        scanResultTabBer.delegate = self
        scanResultScrollView.delegate = self
        //ScanResultViewController.name = namelabel.text!
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem  = UIBarButtonItem(image: UIImage(imageLiteralResourceName: "Back Arrow"), style: .plain, target: self, action: #selector(onBackPressed))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
        self.navigationItem.title = "Scan Result"

        let widthscreen = UIScreen.main.bounds.width
        scanResultScrollView.contentSize = CGSize(width: widthscreen * 3, height: scanResultScrollView.frame.size.height)
        scanResultScrollView.isPagingEnabled = true
        scanResultScrollView.bounces = false
        scanResultScrollView.showsHorizontalScrollIndicator = false
        scanResultScrollView.isScrollEnabled = false

        contentView.frame = CGRect(x: 0, y: 0, width: widthscreen * 3, height: scanResultScrollView.frame.size.height)

//        descriptionView.frame = CGRect(x: 0, y: 0, width: widthscreen, height: scanResultScrollView.frame.size.height)
//        eligibilityView.frame = CGRect(x: 0 + widthscreen, y: 0, width: widthscreen, height: scanResultScrollView.frame.size.height)
//        contactView.frame = CGRect(x: 0 + widthscreen * 2, y: 0, width: widthscreen, height: scanResultScrollView.frame.size.height)
//
        descriptionView.frame.size = CGSize(width: widthscreen, height: scanResultScrollView.frame.size.height)
        eligibilityView.frame.size = CGSize(width: widthscreen, height: scanResultScrollView.frame.size.height)
        contactView.frame.size = CGSize(width: widthscreen, height: scanResultScrollView.frame.size.height)

        setDefault()
    }
    @objc func onBackPressed() {
        self.navigationController?.popViewController(animated: true)
    }

    func setDefault() {

        //cum_tabbar.items![0].setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], for: .normal)
        descriptionbtn.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], for: .normal)

    }

    override func viewDidAppear(_ animated: Bool) {
        tabBarLine.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width / 3, height: 2)

    }

}
extension ScanResultViewController: UIScrollViewDelegate {

}
extension ScanResultViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {

        descriptionbtn.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.init(displayP3Red: 173 / 255, green: 173 / 255, blue: 173 / 255, alpha: 1)], for: .normal)
        descriptionbtn.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.init(displayP3Red: 236 / 255, green: 45 / 255, blue: 72 / 255, alpha: 1)], for: .selected)
        var offset: CGPoint
        var lineoffset: CGPoint
        switch item.title! {
        case "Description":
            offset = CGPoint(x: 0, y: 0)
            lineoffset = CGPoint(x: 0, y: 0)
            tabBarLine.frame = CGRect(x: lineoffset.x, y: lineoffset.y, width: UIScreen.main.bounds.width / 3, height: 2)

            scanResultScrollView.setContentOffset(offset, animated: true)

        case "Eligibility":
            offset = CGPoint(x: UIScreen.main.bounds.width, y: 0)
            lineoffset = CGPoint(x: tabBarLine.frame.width, y: 0)
            tabBarLine.frame = CGRect(x: lineoffset.x, y: lineoffset.y, width: UIScreen.main.bounds.width / 3, height: 2)

            scanResultScrollView.setContentOffset(offset, animated: true)

        case "Contact":
            lineoffset = CGPoint(x: tabBarLine.frame.width * 2, y: 0)
            offset = CGPoint(x: UIScreen.main.bounds.width * 2, y: 0)
            tabBarLine.frame = CGRect(x: lineoffset.x, y: lineoffset.y, width: UIScreen.main.bounds.width / 3, height: 2)
            scanResultScrollView.setContentOffset(offset, animated: true)

        default:
            print("error")
            break
        }
    }

}
