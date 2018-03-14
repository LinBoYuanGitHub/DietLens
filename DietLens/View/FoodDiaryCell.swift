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

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setupCell(foodDiary: FoodDiary) {
        foodName.text = foodDiary.foodName
//        foodImage.image = food.foodImage
        servingSize.text = foodDiary.unit
        calories.text = String(round(10*foodDiary.calorie*foodDiary.portionSize)/1000)+" "+StringConstants.UIString.calorieUnit
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
