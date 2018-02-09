//
//  IngredientSearchController.swift
//  DietLens
//
//  Created by linby on 06/12/2017.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation
import UIKit

class IngredientSearchController: UIViewController {

    @IBOutlet weak var TFaddIngredient: DesignableUITextField!
    @IBOutlet weak var suggestionTableView: UITableView!

    var addIngredientDelegate: AddIngredientDelegate!
    private var ingredientSearchCellIdentifier = "suggestionFoodTableViewCell"

    private var suggestions = [TextSearchSuggestionEntity]()
    private var lastSearchTime = Date()
    var ingredient: Ingredient?
    var isSearching = false

    override func viewDidLoad() {
        TFaddIngredient.tintColor = UIColor.black
        //set up TF Search
        let placeHolderText = NSAttributedString(string: "Search Ingredient", attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray])
        TFaddIngredient.attributedPlaceholder = placeHolderText
        TFaddIngredient.delegate = self
        //set up suggestionTableView
        suggestionTableView.delegate = self
        suggestionTableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden), name: .UIKeyboardWillHide, object: nil)
    }

    @objc func keyboardWasShown (notification: NSNotification) {
        let info: NSDictionary = notification.userInfo! as NSDictionary
        //use UIKeyboardFrameEndUserInfoKey,UIKeyboardFrameBeginUserInfoKey return 0
        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        var contentInsets: UIEdgeInsets
        if UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation) {
            contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardSize?.height)!, right: 0.0)
        } else {
            contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardSize?.height)!, right: 0.0)
        }
        suggestionTableView.contentInset = contentInsets
        suggestionTableView.scrollIndicatorInsets = suggestionTableView.contentInset
    }

    @objc func keyboardWillBeHidden () {
        suggestionTableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func textFieldChanged(_ sender: UITextField) {
        //load suggestion from net, set time
        if Double(Date().timeIntervalSince(lastSearchTime)) > 0.1 {
            lastSearchTime = Date()
            performIngredientSearch()
        }
    }

    func performIngredientSearch() {
        if isSearching {
            APIService.instance.cancelRequest(requestURL: ServerConfig.ingredientSearchURL)
        }
        isSearching = true
        APIService.instance.getIngredientSearchResult(keywords: TFaddIngredient.text!) { (foodSearchList) in
            self.isSearching = false
            if foodSearchList == nil {
                self.suggestions =  [TextSearchSuggestionEntity]()
            } else {
                self.suggestions = foodSearchList!
            }
            self.suggestionTableView.reloadData()
        }
    }

}

extension IngredientSearchController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension IngredientSearchController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "suggestionFoodTableViewCell") else {
            return UITableViewCell()
        }
        cell.imageView?.image = #imageLiteral(resourceName: "search_icon")
        cell.textLabel?.text = suggestions[indexPath.row].name
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let foodId = suggestions[indexPath.row].id
        APIService.instance.getIngredientSearchDetailResult(foodId: foodId) { (ingredient) in
            if ingredient == nil {
                return
            }
            self.ingredient = ingredient
            self.performSegue(withIdentifier: "toIngredientDetaliPage", sender: self)
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

}

extension IngredientSearchController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? AddIngredientViewController {
           dest.ingredient = self.ingredient
        }
    }
}
