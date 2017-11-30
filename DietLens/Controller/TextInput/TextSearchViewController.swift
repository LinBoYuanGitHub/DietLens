//
//  TextSearchViewController.swift
//  DietLens
//
//  Created by linby on 30/11/2017.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation
import UIKit

class TextSearchViewController: UIViewController {

    @IBOutlet weak var TFSearch: DesignableUITextField!
    @IBOutlet weak var suggestionTableView: UITableView!

    private var suggestions = [TextSearchSuggestionEntity]()
    private var suggestionCellIdentifier = "suggestionFoodTableViewCell"

    private var lastSearchTime = Date()

    override func viewDidLoad() {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "Back Arrow"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        button.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(50), height: CGFloat(50))
        button.addTarget(self, action: #selector(self.backToPreviousView), for: .touchUpInside)
        TFSearch.leftView = button
        TFSearch.tintColor = UIColor.black
        //set up TF Search
        let placeHolderText = NSAttributedString(string: "Search Food", attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray])
        TFSearch.attributedPlaceholder = placeHolderText
        TFSearch.delegate = self
        //set up suggestionTableView
        suggestionTableView.delegate = self
        suggestionTableView.dataSource = self
    }

    @IBAction func textFieldChanged(_ sender: UITextField) {
        //load suggestion from net, set time
        if Double(Date().timeIntervalSince(lastSearchTime)) > 0.75 {
            lastSearchTime = Date()
            APIService.instance.getFoodSearchResult(keywords: TFSearch.text!) { (foodSearchList) in
                if foodSearchList == nil {
                    self.suggestions =  [TextSearchSuggestionEntity]()
                } else {
                    self.suggestions = foodSearchList!
                }
                self.suggestionTableView.reloadData()
            }
        }
    }

    @objc func backToPreviousView() {
        dismiss(animated: true, completion: nil)
    }

}

extension TextSearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}

extension TextSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 50
    }

}

extension TextSearchViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "searchSuggestionCellIdentifier") else {
            return UITableViewCell()
        }
        cell.imageView?.image = #imageLiteral(resourceName: "search_icon")
        cell.textLabel?.text = suggestions[indexPath.row].name
        return cell
    }
}
