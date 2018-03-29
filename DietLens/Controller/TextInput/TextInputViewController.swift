//
//  TextInputViewController.swift
//  DietLens
//
//  Created by louis on 11/11/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation
import UIKit
import XLPagerTabStrip

class TextInputViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var addHistoryTable: UITableView!

    var historyDiaryList = [FoodDiaryModel]()
    var selectedFoodDiary = FoodDiaryModel()
    var foodResults = [FoodInfomation]()
    var selectedImageView: UIImage?
    var targetPortion: Double?
    var addFoodDate: Date?

    // Should reload table when this is changed

//    private var addFoodHistoryList = [FoodInfomation]()
//
//    private let suggestions = ["Laksa", "Chili Crab", "Chicken Rice", "Oyster Omelette"]
//    private let suggestionCellIdentifier = "suggestionFoodTableViewCell"
    //    private var filteredSuggesvarnvarString] {
//        guard let searchText = textField.text else {
//            return []
//        }
//        let processedSearchText = searchText.trimmingCharacters(in: .whitespaces).lowercased()
//        guard processedSearchText.lengthOfBytes(using: .utf8) >= 2 else {
//            return []
//        }
//        return suggestions.filter { $0.lowercased().contains(searchText) }
//    }

//    @IBAction func textFieldTouched(_ sender: UITextField) {
//        performSegue(withIdentifier: "searchFood", sender: self)
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addHistoryTable.delegate = self
        addHistoryTable.dataSource = self
        textField.delegate = self
        loadHistoryItem()
    }

    func loadHistoryItem() {
        historyDiaryList = FoodDiaryDBOperation.instance.getRecentAddedFoodDiary(limit: 3)
        addHistoryTable.reloadData()
    }

}

extension TextInputViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyDiaryList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //fill in tableview
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "addFoodHistoryCellIdentifier") as? HistoryFoodDiaryCell else {
            return UITableViewCell()
        }
        let foodDiary  = historyDiaryList[indexPath.row]
        cell.setUpCell(imagePath: foodDiary.imagePath, foodNameString: foodDiary.foodInfoList[foodDiary.selectedFoodInfoPos].foodName, foodCal: String(round(foodDiary.foodInfoList[foodDiary.selectedFoodInfoPos].calorie)))
        return cell
    }

}

extension TextInputViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        performSegue(withIdentifier: "searchFood", sender: self)
        return false
    }

}

extension TextInputViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFoodDiary = historyDiaryList[indexPath.row]
        // Row selected, so set textField to relevant value, hide tableView
        //calculation for individual nutrition
        selectedImageView = (tableView.cellForRow(at: indexPath) as! HistoryFoodDiaryCell).foodDiaryImage.image
        //perform segue
        performSegue(withIdentifier: "historyToResult", sender: self)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.addHistoryTable {
            return 60
        }
        return 0
    }
}

extension TextInputViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "BY TEXT")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? RecognitionResultsViewController {
            dest.foodDiary.recordType = selectedFoodDiary.recordType
            for ingredient in selectedFoodDiary.ingredientList {
                dest.foodDiary.ingredientList.append(ingredient)
            }
            dest.foodDiary = selectedFoodDiary
            dest.foodDiary.recordType = RecordType.RecordByText
            dest.userFoodImage = selectedImageView
            guard let parentVC = self.parent as? AddFoodViewController else {
                dest.dateTime = Date()
                return
            }
            dest.isSetMealByTimeRequired = false
            dest.whichMeal = parentVC.mealType
            dest.dateTime = parentVC.addFoodDate
        }
        if let dest = segue.destination as? TextSearchViewController {
            guard let parentVC = self.parent as? AddFoodViewController else {
                dest.addFoodDate = Date()
                return
            }
            dest.addFoodDate = parentVC.addFoodDate
            dest.isSetMealByTimeRequired = parentVC.isSetMealByTimeRequired
            dest.mealType = parentVC.mealType
        }
    }
}
