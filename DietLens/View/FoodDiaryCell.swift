//
//  FoodDiaryCell.swift
//  DietLens
//
//  Created by next on 7/11/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit

class FoodDiaryCell: UITableViewCell {
    @IBOutlet weak var servingSize: UILabel!
    @IBOutlet weak var foodName: UILabel!
    @IBOutlet weak var calories: UILabel!

    @IBOutlet weak var foodImage: RoundedImage!

    var food: FoodInfo = FoodInfo()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setupCell(foodInfo: FoodInfo) {
        food = foodInfo
        foodName.text = food.foodName
//        foodImage.image = food.foodImage
        servingSize.text = food.servingSize
        servingSize.isHidden = true
        calories.text = String(round(10*foodInfo.calories*foodInfo.portionSize)/1000)+" Kcal"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
