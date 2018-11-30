//
//  profileTextFieldCell.swift
//  DietLens
//
//  Created by linby on 2018/7/2.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
class ProfileTextFieldCell: UITableViewCell {

    @IBOutlet weak var inptText: UITextField!
    @IBOutlet weak var txtLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setUpCell(keyText: String, valueText: String) {
        txtLabel.text = keyText
        inptText.text = valueText

    }
}
