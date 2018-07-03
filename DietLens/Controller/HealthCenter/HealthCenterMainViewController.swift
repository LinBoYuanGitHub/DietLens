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

    let itemArray = ["Weight", "Blood glucose", "Mood"]
    var latestRecordArray = [HealthCenterRecord]() // 3 latest item

    override func viewDidLoad() {
        super.viewDidLoad()
        healthCenterTable.delegate = self
        healthCenterTable.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.topItem?.title = "Health Center"
        let textColor = UIColor(red: CGFloat(67/255), green: CGFloat(67/255), blue: CGFloat(67/255), alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: textColor, kCTFontAttributeName: UIFont(name: "PingFangSC-Regular", size: 18)!] as! [NSAttributedStringKey: Any]
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }

    func getLatestHealthCenterItemValue() {
        //use mockedUp data
        let latestWeight = HealthCenterRecord.init(type: "0", itemName: "Weight", value: 50, unit: "kg", date: Date())
        let latestBloodGlucose = HealthCenterRecord.init(type: "1", itemName: "Blood glucose", value: 5.6, unit: "mmol/L", date: Date())
        let latestMood = HealthCenterRecord.init(type: "2", itemName: "Mood", value: 2, unit: "", date: Date())
        latestRecordArray.append(latestWeight)
        latestRecordArray.append(latestBloodGlucose)
        latestRecordArray.append(latestMood)
        healthCenterTable.reloadData()
    }

}

extension HealthCenterMainViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //jump to healthCenterTableViewVC
        if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HealthCenterTable") as? HealthCenterTableViewController {
            let entity = latestRecordArray[indexPath.row]
            dest.recordType  = entity.type
            dest.recordName = entity.itemName
            self.navigationController?.pushViewController(dest, animated: true)
        }
    }

}
