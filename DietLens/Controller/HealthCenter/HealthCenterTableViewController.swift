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
    var recordList = [HealthCenterRecord]()

    override func viewDidLoad() {
        super.viewDidLoad()
        healthCenterBarTable.delegate = self
        healthCenterBarTable.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        //add record name
        self.navigationController?.navigationBar.topItem?.title = recordName
        let textColor = UIColor(red: CGFloat(67/255), green: CGFloat(67/255), blue: CGFloat(67/255), alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: textColor, kCTFontAttributeName: UIFont(name: "PingFangSC-Regular", size: 18)!] as! [NSAttributedStringKey: Any]
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }

    func addRightNavigationButton() {
        let rightNavButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(onAddItem))
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

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

}
