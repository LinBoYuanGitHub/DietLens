//
//  HealthDeviceDataCell.swift
//  DietLens
//
//  Created by linby on 17/01/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
class HealthDeviceDataCell: UITableViewCell {

    @IBOutlet weak var statistic: UILabel!
    @IBOutlet weak var date: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setupCell( value: String, unit: String, dateStr: String) {
        self.statistic.text = value+unit
        self.date.text = dateStr
    }
}
