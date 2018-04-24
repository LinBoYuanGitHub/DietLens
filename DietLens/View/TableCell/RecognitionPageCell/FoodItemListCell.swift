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
        quantityLable.text = String(dietItem.quantity)
//        unitLabel.text = dietItem.portionInfo[dietItem.selectedPos].weightUnit
        calorieLabel.text = String(dietItem.nutritionInfo.calorie)
    }

}
