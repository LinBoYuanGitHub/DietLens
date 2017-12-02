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
    // Should reload table when this is changed

//    private var addFoodHistoryList = [FoodInfomation]()
//
//    private let suggestions = ["Laksa", "Chili Crab", "Chicken Rice", "Oyster Omelette"]
//    private let suggestionCellIdentifier = "suggestionFoodTableViewCell"
//    private var filteredSuggestion: [String] {
//        guard let searchText = textField.text else {
//            return []
//        }
//        let processedSearchText = searchText.trimmingCharacters(in: .whitespaces).lowercased()
//        guard processedSearchText.lengthOfBytes(using: .utf8) >= 2 else {
//            return []
//        }
//        return suggestions.filter { $0.lowercased().contains(searchText) }
//    }

    @IBAction func textFieldTouched(_ sender: UITextField) {
        performSegue(withIdentifier: "searchFood", sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addHistoryTable.delegate = self
        addHistoryTable.dataSource = self
        textField.delegate = self
    }

}

extension TextInputViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count: Int = 3
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            //fill in tableview
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "addFoodHistoryCellIdentifier") else {
                return UITableViewCell()
            }
            cell.imageView?.image = #imageLiteral(resourceName: "food_sample_image")
            cell.textLabel?.text = "Rice"
            cell.detailTextLabel?.text = "456 kcal"
            return cell
    }
}

extension TextInputViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
}

extension TextInputViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Row selected, so set textField to relevant value, hide tableView
        // endEditing can trigger some other action according to requirements
        if tableView == self.addHistoryTable {
           //do something on item click
        }
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
}
