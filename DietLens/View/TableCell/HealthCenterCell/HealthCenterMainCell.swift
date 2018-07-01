//
//  HealthCenterMainCell.swift
//  DietLens
//
//  Created by linby on 2018/6/29.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class HealthCenterMainCell: UITableViewCell {
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setUpCell(recordType: String, latestValue: String, dateTime: String) {
        switch recordType {
        case "0":
            itemName.text = "Weight"
        case "1":
            itemName.text = "Blood glucose"
        case "2":
            itemName.text = "Mood"
        default:
            break
        }
    }

}
