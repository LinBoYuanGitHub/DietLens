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
    var titleName = ""
    //data type
    var recordList = [HealthCenterItem]()
    @IBOutlet weak var emptyViewContainer: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        healthCenterBarTable.delegate = self
        healthCenterBarTable.dataSource = self
        healthCenterBarTable.tableFooterView = UIView()
    }

    func getHealthItemData() {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        appdelegate.showLoadingDialog()
        APIService.instance.getHealthLogByCategory(category: recordName) { (healthLogs) in
            appdelegate.dismissLoadingDialog()
            if healthLogs == nil {
                self.emptyViewContainer.isHidden = false
                return
            }
            if healthLogs?.count == 0 {
                 self.emptyViewContainer.isHidden = false
            } else {
                 self.emptyViewContainer.isHidden = true
            }
            self.recordList = healthLogs!
            self.healthCenterBarTable.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
        //navigation controller
        self.navigationController?.navigationBar.isHidden = false
        //add record name
        self.navigationItem.title = titleName
        let textColor = UIColor(red: CGFloat(67/255), green: CGFloat(67/255), blue: CGFloat(67/255), alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: textColor, kCTFontAttributeName: UIFont(name: "PingFangSC-Regular", size: 18)!] as? [NSAttributedStringKey: Any]
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

    func deleteHealthItem(row: Int) {
        APIService.instance.deleteHealthCenterData(healthItemId: recordList[row].id) { (isSuccess) in
            if isSuccess {
                self.recordList.remove(at: row)
                let indexPath = IndexPath(row: row, section: 0)
                self.healthCenterBarTable.deleteRows(at: [indexPath], with: .automatic)
                if self.recordList.count == 0 {
                    self.emptyViewContainer.isHidden = false
                }
            }
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

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //API delete item
            deleteHealthItem(row: indexPath.row)
        }
    }

    func findMaxValue(recordList: [HealthCenterItem]) -> Float {
        var maxValue: Float = 0
        for record in recordList where record.value > maxValue {
                maxValue = record.value
        }
        return maxValue
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "healthCenterBarCell") as? HealthCenterBarCell {
            let entity = recordList[indexPath.row]
            cell.setUpCell(category: entity.category, value: entity.value,
                           maxValue: findMaxValue(recordList: recordList), dateStr: entity.date, timeStr: entity.time)
            return cell
        }
        return UITableViewCell()
    }

}
