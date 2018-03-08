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

    @IBOutlet weak var recognitzeDataTable: UITableView!
    @IBOutlet weak var header: UIStackView!
//    @IBOutlet weak var TFportion: UITextField!

    @IBOutlet weak var TFunit: UITextField!
    @IBOutlet weak var TFquantity: UITextField!
    @IBOutlet weak var TFmealType: UITextField!
    @IBOutlet weak var TFfoodName: UITextField!
    @IBOutlet weak var caloriePercentage: UILabel!
//    @IBOutlet weak var portionStack: UIStackView!
    @IBOutlet weak var quantityStack: UIStackView!
    @IBOutlet weak var unitStack: UIStackView!

    @IBOutlet weak var mainStackView: UIStackView!
    var ingredientAdapter: PlainTextTableAdapter<UITableViewCell>!
    @IBOutlet weak var diaryFoodCarlorieLabel: UILabel!
    var selectedFoodInfo = FoodInfo()
    var diaryImage: UIImage?

    override func viewDidLoad() {
        TFfoodName.text = selectedFoodInfo.foodName
//        TFportion.text = String(selectedFoodInfo.portionSize)+"%"
        TFmealType.text = selectedFoodInfo.mealType

        TFfoodName.isUserInteractionEnabled = false
        TFquantity.isUserInteractionEnabled = false
        TFunit.isUserInteractionEnabled = false
        TFmealType.isUserInteractionEnabled = false
//        TFportion.isUserInteractionEnabled = false
        diaryFoodImage.contentMode = .scaleAspectFill
        diaryFoodImage.image = diaryImage
        recognitzeDataTable.tableHeaderView = header
        recognitzeDataTable.tableHeaderView?.fs_height = 550
        ingredientAdapter = PlainTextTableAdapter()
        recognitzeDataTable.delegate = ingredientAdapter
        recognitzeDataTable.dataSource = ingredientAdapter
        //register tableview header
        let nib = UINib(nibName: "IngredientHeader", bundle: nil)
        recognitzeDataTable.register(nib, forHeaderFooterViewReuseIdentifier: "IngredientSectionHeader")
        ingredientAdapter.isShowPlusBtn = false
        setFoodDataList()
        loadIngredients()
        if selectedFoodInfo.recordType == "customized"{
//            portionStack.isHidden = true
            quantityStack.isHidden = true
            unitStack.isHidden = true
            recognitzeDataTable.tableHeaderView?.fs_height = (recognitzeDataTable.tableHeaderView?.fs_height)! - CGFloat(100)
        } else {
//            portionStack.isHidden = false
            quantityStack.isHidden = false
            unitStack.isHidden = false
        }
    }

    func loadIngredients() {
        if selectedFoodInfo.ingredientList.count != 0 {
            ingredientAdapter.isShowIngredient = true
            for ingredient in selectedFoodInfo.ingredientList {
                ingredientAdapter.ingredientTextList.append(ingredient.ingredientName + "  " + String(ingredient.quantity*ingredient.weight) + "g")
            }
            recognitzeDataTable.reloadData()
        }
    }

    func setFoodDataList() {
        ingredientAdapter.nutritionTextList.removeAll()
        let total_calories = round(10*Double(selectedFoodInfo.calories)*selectedFoodInfo.portionSize)/1000
        let total_carbohydrate = round(10*Double(selectedFoodInfo.carbohydrate)!*selectedFoodInfo.portionSize)/1000
        let total_protein = round(10*Double(selectedFoodInfo.protein)!*selectedFoodInfo.portionSize)/1000
        let total_fat = round(10*Double(selectedFoodInfo.fat)!*selectedFoodInfo.portionSize)/1000
        ingredientAdapter.nutritionTextList.append("Calories   \(String(total_calories))kcal")
        ingredientAdapter.nutritionTextList.append("Carbs   \(String(total_carbohydrate))g")
        ingredientAdapter.nutritionTextList.append("Protein   \(String(total_protein))g")
        ingredientAdapter.nutritionTextList.append("Fats   \(String(total_fat))g")
        recognitzeDataTable.reloadData()
        //adjust calorie textlabel
//        TFportion.text = "\(round(selectedFoodInfo.portionSize))%"
        TFquantity.text = String(round(selectedFoodInfo.quantity))
        TFunit.text = selectedFoodInfo.unit
        diaryFoodCarlorieLabel.text = "\(round(total_calories)) kcal"
        caloriePercentage.text = "\(round(total_calories/20))% of your daily calorie intake"
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func deleteButtonPressed(_ sender: Any) {
//        FoodDiaryDBOperation.instance.deleteFoodDiary(id: foodDiary.id)
        AlertMessageHelper.showOkCancelDialog(targetController: self, title: "", message: "Do you want to delete \(selectedFoodInfo.foodName)?", postiveText: "yes", negativeText: "no") { (flag) in
            if flag {
                FoodDiaryDBOperation.instance.deleteFoodDiary(id: self.selectedFoodInfo.id)
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
}
