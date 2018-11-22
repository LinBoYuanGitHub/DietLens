//
//  SingleSelectionCell.swift
//  DietLens
//
//  Created by linby on 2018/5/21.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
class SingleSelectionCell: UITableViewCell {

    @IBOutlet weak var selectionText: UILabel!
    @IBOutlet weak var indicator: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setUpCell(text: String, isSelected: Bool) {
        self.selectionText.text = text
        self.indicator.isHidden = !isSelected
    }
}
