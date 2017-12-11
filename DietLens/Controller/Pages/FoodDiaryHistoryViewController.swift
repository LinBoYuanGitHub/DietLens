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
    var selectedFoodInfo = FoodInfo()
    var diaryImage: UIImage?

    @IBOutlet weak var ingredientStack: UIStackView!
    @IBOutlet weak var nutritionStack: UIStackView!
    @IBOutlet weak var portionStack: UIStackView!

    @IBOutlet weak var ingredientTable: UITableView!
    @IBOutlet weak var nutritionTable: UITableView!

    override func viewDidLoad() {
        TFfoodName.text = selectedFoodInfo.foodName
        TFportion.text = "100%"
        TFmealType.text = ""
        diaryFoodCarlorieLabel.text = "\(selectedFoodInfo.calories) kcal"

        TFfoodName.isUserInteractionEnabled = false
        TFportion.isUserInteractionEnabled = false
        TFmealType.isUserInteractionEnabled = false
        diaryFoodImage.image = diaryImage
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func deleteButtonPressed(_ sender: Any) {
//        FoodDiaryDBOperation.instance.deleteFoodDiary(id: foodDiary.id)
        dismiss(animated: true, completion: nil)
    }
}
