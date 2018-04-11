//
//  textSearchAutoCompleteCell.swift
//  DietLens
//
//  Created by linby on 08/04/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class AutoCompleteCell: UITableViewCell {

    @IBOutlet weak var autoCompleteText: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setUpCell(text: String) {
        autoCompleteText.text = text
    }
}
