//
//  HealthToolCell.swift
//  DietLens
//
//  Created by linby on 16/01/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
class HealthToolCell: UITableViewCell {
    @IBOutlet weak var deviceIcon: UIImageView!

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var lastRecord: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setupCell(icon: UIImage, title: String, lastRecord: String) {
        self.deviceIcon.image = icon
        self.title.text = title
        self.lastRecord.text = "Last Record: "+lastRecord
    }
}
