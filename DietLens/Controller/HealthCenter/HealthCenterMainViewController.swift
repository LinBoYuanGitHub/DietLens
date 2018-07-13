//
//  HealthCenterMainViewController.swift
//  DietLens
//
//  Created by linby on 2018/6/29.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

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
    }

    func getLatestHealthCenterItemValue() {
        APIService.instance.getLatestHealthLog { (healthCenterItems) in
            if healthCenterItems != nil {
                self.healthCenterItemList = healthCenterItems!
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
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //jump to healthCenterTableViewVC
        if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HealthCenterTableVC")
            as? HealthCenterTableViewController {
            tableView.deselectRow(at: indexPath, animated: true)
            let entity = healthCenterItemList[indexPath.row]
            dest.recordType  = entity.type
            dest.recordName = entity.itemName
            self.navigationController?.pushViewController(dest, animated: true)
        }
    }

}
