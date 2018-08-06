//
//  ProfileArrowCell.swift
//  DietLens
//
//  Created by linby on 2018/7/2.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
class ProfileArrowCell: UITableViewCell {
    @IBOutlet weak var textComponent: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setUpCell(text: String) {
        textComponent.text = text
    }
}
