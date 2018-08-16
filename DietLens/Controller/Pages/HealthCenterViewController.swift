//
//  HealthCenterController.swift
//  DietLens
//
//  Created by linby on 16/01/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class HealthCenterViewController: UIViewController {

    @IBOutlet weak var healthCenterTable: UITableView!
//    var recordList = [HealthCenterItem]()

    override func viewDidLoad() {
        healthCenterTable.delegate = self
        healthCenterTable.dataSource = self
        healthCenterTable.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
        //navigation controller
        self.navigationController?.navigationBar.isHidden = false
        let textColor = UIColor(red: CGFloat(67/255), green: CGFloat(67/255), blue: CGFloat(67/255), alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: textColor, kCTFontAttributeName: UIFont(name: "PingFangSC-Regular", size: 18)!] as! [NSAttributedStringKey: Any]
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }

}

extension HealthCenterViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return recordList.count
        return 3
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if let cell = tableView.dequeueReusableCell(withIdentifier: "healthCenterMainCell", for: indexPath) as? HealthCenterMainCell {
//            let entity = recordList[indexPath.row]
//            cell.setUpCell(recordType: entity.type, latestValue: String(entity.value) + entity.unit , dateTime: "Today,6:06PM")
//        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

}
