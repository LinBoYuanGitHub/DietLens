//
//  actvitityLevelCell.swift
//  DietLens
//
//  Created by linby on 2018/9/17.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class ActvitityLevelCell: UITableViewCell {

    @IBOutlet weak var activityLevelLabel: UILabel!
    @IBOutlet weak var activityLevelDesc: UILabel!
    @IBOutlet weak var borderView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setUpCell(titleText: String, descText: String) {
        activityLevelLabel.text = titleText
        activityLevelDesc.text = descText
    }

}
