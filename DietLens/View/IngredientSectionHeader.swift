//
//  IngredientSectionHeader.swift
//  DietLens
//
//  Created by linby on 06/01/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
class IngredientSectionHeader: UITableViewHeaderFooterView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var plusButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func onPlusBtnPressed(_ sender: Any) {
        NotificationCenter.default.post(name: .onIngredientPlusBtnClick, object: nil)
    }

}
