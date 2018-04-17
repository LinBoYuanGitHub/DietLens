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

    func setUpCell(foodName: String, quantity: Int, unit: String, calorie: Double) {
        foodNameLable.text = foodName
        quantityLable.text = String(quantity)
        unitLabel.text = unit
        calorieLabel.text = String(calorie)
    }

}
