//
//  EligibilityTableCell.swift
//  DietLens
//
//  Created by boyuan lin on 13/12/18.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class EligibilityTableCell: UITableViewCell {
    @IBOutlet weak var criteriaNameLabel: UILabel!
    @IBOutlet weak var criteriaValueLabel: UILabel!

    func setUpCell(criteriaNameText: String, criteriaValText: String) {
        criteriaNameLabel.text = criteriaNameText + ":"
        criteriaValueLabel.text = criteriaValText
    }
}
