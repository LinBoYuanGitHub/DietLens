//
//  HealthCenterTableViewController.swift
//  DietLens
//
//  Created by linby on 2018/6/29.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
class HealthCenterTableViewController: UIViewController {

    @IBOutlet weak var healthCenterBarTable: UITableView!
    //data passing part
    var recordType = ""
    var recordName = ""
    //data type
    var recordList = [HealthCenterItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        healthCenterBarTable.delegate = self
        healthCenterBarTable.dataSource = self
        healthCenterBarTable.tableFooterView = UIView()
    }

    func getHealthItemData() {
        AlertMessageHelper.showLoadingDialog(targetController: self)
        APIService.instance.getHealthLogByCategory(category: recordName) { (healthLogs) in
            AlertMessageHelper.dismissLoadingDialog(targetController: self)
            if healthLogs == nil {
                return
            }
            self.recordList = healthLogs!
            self.healthCenterBarTable.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
        //navigation controller
        self.navigationController?.navigationBar.isHidden = false
        //disable sidebarMenu effort
        self.sideMenuController?.isLeftViewSwipeGestureEnabled = false
        //add record name
        self.navigationItem.title = recordName
        let textColor = UIColor(red: CGFloat(67/255), green: CGFloat(67/255), blue: CGFloat(67/255), alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: textColor, kCTFontAttributeName: UIFont(name: "PingFangSC-Regular", size: 18)!] as! [NSAttributedStringKey: Any]
        self.navigationItem.leftBarButtonItem =  UIBarButtonItem(image: #imageLiteral(resourceName: "Back Arrow"), style: .plain, target: self, action: #selector(onBackPressed))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1.0)
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        addRightNavigationButton()
        getHealthItemData()
    }

    @objc func onBackPressed() {
        self.navigationController?.popViewController(animated: true)
    }

    func addRightNavigationButton() {
        let rightNavButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(onAddItem))
        rightNavButton.tintColor = UIColor(red: 94/255, green: 94/255, blue: 94/255, alpha: 1)
        self.navigationItem.rightBarButtonItem = rightNavButton
    }

    @objc func onAddItem() {
        //to add single item page
        if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HealthCenterAddItemVC") as? HealthCenterAddItemViewController {
            dest.recordType  = recordType
            dest.recordName = recordName
            self.navigationController?.pushViewController(dest, animated: true)
        }
    }
}

extension HealthCenterTableViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordList.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }

    func findMaxValue(recordList: [HealthCenterItem]) -> Float {
        var maxValue: Float = 0
        for record in recordList {
            if record.value > maxValue {
                maxValue = record.value
            }
        }
        return maxValue
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "healthCenterBarCell") as? HealthCenterBarCell {
            let entity = recordList[indexPath.row]
            cell.setUpCell(category: entity.category, value: entity.value, maxValue: findMaxValue(recordList: recordList), dateStr: entity.date, timeStr: entity.time)
            return cell
        }
        return UITableViewCell()
    }

}
