//
//  HealthCenterMainViewController.swift
//  DietLens
//
//  Created by linby on 2018/6/29.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class HealthCenterMainViewController: UIViewController {

    @IBOutlet weak var healthCenterTable: UITableView!
    //data part
//    let iconArray = []
    var healthCenterItemList = [HealthCenterItem]() // 3 latest item

    override func viewDidLoad() {
        super.viewDidLoad()
        healthCenterTable.delegate = self
        healthCenterTable.dataSource = self
        healthCenterTable.tableFooterView = UIView()
        //analytic screen name
        Analytics.setScreenName("HealthLogPage", screenClass: "HealthCenterMainViewController")
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.topItem?.title = "Health Log"
        let textColor = UIColor(red: CGFloat(67/255), green: CGFloat(67/255), blue: CGFloat(67/255), alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: textColor,
                                                                        kCTFontAttributeName: UIFont(name: "PingFangSC-Regular", size: 18)!] as? [NSAttributedStringKey: Any]
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        getLatestHealthCenterItemValue()
        //set rightBarButtonItem disapear
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }

    /**
     * Append Step Counter tab as the first persistent Item
     */
    func getLatestHealthCenterItemValue() {
        APIService.instance.getLatestHealthLog { (healthCenterItems) in
            if healthCenterItems != nil {
                self.healthCenterItemList = healthCenterItems!
                //add stepCounter item
                var stepCounterItem = HealthCenterItem()
                stepCounterItem.itemName = "Step Counter"
                stepCounterItem.category = StringConstants.UIString.stepCounterText
                stepCounterItem.type = "3"
                self.healthCenterItemList.insert(stepCounterItem, at: 0)
                //reload table view
                self.healthCenterTable.reloadData()
            }
        }

    }

}

extension HealthCenterMainViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return healthCenterItemList.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "healthCenterMainCell", for: indexPath) as? HealthCenterMainCell {
            let item = healthCenterItemList[indexPath.row]
            cell.setUpCell(recordType: item.type, latestValue: item.value, dateTime: item.date + " , " + item.time)
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //jump to healthCenterTableViewVC
        let entity = healthCenterItemList[indexPath.row]
        if entity.category == StringConstants.UIString.stepCounterText {
            if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StepChartVC") as? StepChartViewController, let cell = tableView.cellForRow(at: indexPath) as? HealthCenterMainCell {
                 self.navigationController?.pushViewController(dest, animated: true)
            }
//            if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StepCounterVC")
//                as? StepCounterViewController, let cell = tableView.cellForRow(at: indexPath) as? HealthCenterMainCell {
//                self.navigationController?.pushViewController(dest, animated: true)
//            }
        } else {
            if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HealthCenterTableVC")
                as? HealthCenterTableViewController, let cell = tableView.cellForRow(at: indexPath) as? HealthCenterMainCell {
                tableView.deselectRow(at: indexPath, animated: true)
                dest.recordType  = entity.type
                dest.recordName = entity.itemName
                dest.titleName = cell.itemName!.text!
                self.navigationController?.pushViewController(dest, animated: true)
            }
        }
    }

}
