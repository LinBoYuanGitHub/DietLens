//
//  ingredientItemCell.swift
//  DietLens
//
//  Created by linby on 23/01/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import Foundation
import UIKit
class IngredientItemCell: UITableViewCell {
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var ingredientText: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setUpCell(ingredientName: String) {
        ingredientText.text = ingredientName
    }

}
