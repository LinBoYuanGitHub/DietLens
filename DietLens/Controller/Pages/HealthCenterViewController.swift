//
//  HealthCenterController.swift
//  DietLens
//
//  Created by linby on 16/01/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class HealthCenterViewController: BaseViewController {

    @IBOutlet weak var healthCenterTable: UITableView!
//    var recordList = [HealthCenterItem]()

    override func viewDidLoad() {
        healthCenterTable.delegate = self
        healthCenterTable.dataSource = self
        healthCenterTable.tableFooterView = UIView()
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
