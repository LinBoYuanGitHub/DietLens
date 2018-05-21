//
//  FoodItemListCell.swift
//  DietLens
//
//  Created by linby on 17/04/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class FoodItemListCell: UITableViewCell {
    @IBOutlet weak var foodNameLable: UILabel!
    @IBOutlet weak var quantityLable: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var calorieLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setUpCell(dietItem: DietItem) {
        foodNameLable.text = dietItem.foodName
        if floor(dietItem.quantity) == dietItem.quantity {
            quantityLable.text = String(Int(dietItem.quantity))
        } else {
            quantityLable.text = String(dietItem.quantity)
        }
        unitLabel.text = dietItem.displayUnit
        calorieLabel.text = String(Int(dietItem.nutritionInfo.calorie)) + StringConstants.UIString.calorieUnit
    }

}
