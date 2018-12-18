//
//  EligibilityViewController.swift
//  DietLens
//
//  Created by 马胖 on 10/12/18.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class EligibilityViewController: UIViewController {

    @IBOutlet weak var criteriaTextTableView: UITableView!
    var inclusiveCriteria = [Criteria]()
    var exclusiveCriteria = [Criteria]()

    var itemInfo: IndicatorInfo = "Eligibility"

    override func viewDidLoad() {
        super.viewDidLoad()
        criteriaTextTableView.dataSource = self
        criteriaTextTableView.delegate = self
    }

}

extension EligibilityViewController: IndicatorInfoProvider {

    // MARK: - IndicatorInfoProvider
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}

extension EligibilityViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section == 0 {
            return inclusiveCriteria.count
        } else if section == 1 {
            return exclusiveCriteria.count
        }

        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: "eligibilityTableCell") as? EligibilityTableCell {

            if indexPath.section == 0 {
                cell.setUpCell(criteriaNameText: inclusiveCriteria[indexPath.row].name, criteriaValText: inclusiveCriteria[indexPath.row].value)
            } else if indexPath.section == 1 {
                cell.setUpCell(criteriaNameText: exclusiveCriteria[indexPath.row].name, criteriaValText: exclusiveCriteria[indexPath.row].value)
            }

            return cell
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UITableViewHeaderFooterView()
        header.contentView.backgroundColor = .white
        header.textLabel?.fs_height = 50
        header.textLabel?.frame.origin.x = 0
        header.textLabel?.font = UIFont(name: "PingFangSC-Light", size: 14)
        header.textLabel?.numberOfLines = 3

        if section == 0 {
            header.textLabel?.text = "You may be eligible for this study if you meet the following criteria:"
        } else if section == 1 {
            header.textLabel?.text = "Exclusion Criteria:"
        }

        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

}
