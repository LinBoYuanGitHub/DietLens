//
//  HealthCenterTableValueCell.swift
//  DietLens
//
//  Created by linby on 2018/7/9.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class HealthCenterTableValueCell: UITableViewCell {
    @IBOutlet weak var healthCenterLabel: UILabel!
    @IBOutlet weak var healthCenterTextField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setUpCell(labelText: String, inputText: String) {
        healthCenterLabel.text = labelText
        healthCenterTextField.text = inputText
    }
}
