//
//  FoodDiaryHistoryViewController.swift
//  DietLens
//
//  Created by linby on 16/11/2017.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation
import UIKit

class FoodDiaryHistoryViewController: UIViewController {
    @IBOutlet weak var diaryFoodImage: UIImageView!

    @IBOutlet weak var TFportion: UITextField!
    @IBOutlet weak var TFmealType: UITextField!
    @IBOutlet weak var TFfoodName: UITextField!

    @IBOutlet weak var diaryFoodCarlorieLabel: UILabel!
    var foodDiary = FoodDiary()
    var diaryImage: UIImage?

    override func viewDidLoad() {
        TFfoodName.text = foodDiary.foodName
        TFportion.text = "\(foodDiary.portionSize*100)%"
        TFmealType.text = foodDiary.mealType
        diaryFoodCarlorieLabel.text = "\(foodDiary.calorie) kcal"
        TFfoodName.isUserInteractionEnabled = false
        TFportion.isUserInteractionEnabled = false
        TFmealType.isUserInteractionEnabled = false
        diaryFoodImage.image = diaryImage
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
