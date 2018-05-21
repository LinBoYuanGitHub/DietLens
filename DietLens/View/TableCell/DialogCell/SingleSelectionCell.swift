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

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setUpCell(text: String) {
        self.selectionText.text = text
    }
}
