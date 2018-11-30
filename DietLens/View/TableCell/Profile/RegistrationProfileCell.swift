//
//  RegistrationProfileCell.swift
//  DietLens
//
//  Created by linby on 2018/9/19.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class RegistrationProfileCell: UITableViewCell {

    @IBOutlet weak var registrationLabel: UILabel!
    @IBOutlet weak var registrationTextField: UITextField!

    func setUpCell(fieldName: String) {
        registrationLabel.text = fieldName
    }
}
