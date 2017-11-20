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
    @IBOutlet weak var suggestionTableView: UITableView!
    @IBOutlet weak var suggestionHeightConstraint: NSLayoutConstraint!
    // Should reload table when this is changed
    private let suggestions = ["Laksa", "Chili Crab", "Chicken Rice", "Oyster Omelette"]
    private let suggestionCellIdentifier = "suggestionFoodTableViewCell"
    private var filteredSuggestion: [String] {
        guard let searchText = textField.text else {
            return []
        }
        let processedSearchText = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        guard processedSearchText.lengthOfBytes(using: .utf8) >= 2 else {
            return []
        }
        return suggestions.filter { $0.lowercased().contains(searchText) }
    }

    @IBAction func textFieldTouched(_ sender: UITextField) {
        suggestionTableView.isHidden = false
    }

    // If user changes text, hide the suggestion list
    @IBAction func textFieldChanged(_ sender: UITextField) {
        suggestionTableView.isHidden = false
        suggestionHeightConstraint.constant = CGFloat(filteredSuggestion.count) * 40
        suggestionTableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        suggestionTableView.register(UITableViewCell.self, forCellReuseIdentifier: suggestionCellIdentifier)

        suggestionTableView.delegate = self
        suggestionTableView.dataSource = self

        textField.delegate = self

        suggestionTableView.isHidden = true
    }

    // Manage keyboard and tableView visibility
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch: UITouch = touches.first else { return }

        if touch.view != suggestionTableView && touch.view != textField {
            textField.endEditing(true)
            suggestionTableView.isHidden = true
        }
    }
}

extension TextInputViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSuggestion.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: suggestionCellIdentifier) else {
            return UITableViewCell()
        }
        // Set text from the data model
        cell.textLabel?.text = filteredSuggestion[indexPath.row]
        cell.textLabel?.font = textField.font
        return cell
    }
}

extension TextInputViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension TextInputViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Row selected, so set textField to relevant value, hide tableView
        // endEditing can trigger some other action according to requirements
        textField.text = filteredSuggestion[indexPath.row]
        tableView.isHidden = true
        textField.endEditing(true)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}

extension TextInputViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "BY TEXT")
    }
}
