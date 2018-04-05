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

    func setupCell(foodDiary: FoodDiaryModel) {
        foodName.text = foodDiary.foodInfoList[foodDiary.selectedFoodInfoPos].foodName
//        foodImage.image = food.foodImage
        servingSize.text = foodDiary.foodInfoList[foodDiary.selectedFoodInfoPos].portionList[foodDiary.selectedPortionPos].weightUnit
        let ratio = foodDiary.quantity * foodDiary.foodInfoList[foodDiary.selectedFoodInfoPos].portionList[foodDiary.selectedPortionPos].weightValue/100
        let calorieValue = Double(foodDiary.foodInfoList[foodDiary.selectedFoodInfoPos].calorie)*ratio
        calories.text = String(format: "%.1f", calorieValue) + " " + StringConstants.UIString.calorieUnit
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
