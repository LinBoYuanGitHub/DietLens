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
    var foodResults = [FoodInfomation]()

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

    override func viewWillAppear(_ animated: Bool) {
        //regist notification
        NotificationCenter.default.removeObserver(self, name: .addDiaryDismiss, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden), name: .UIKeyboardWillHide, object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(onNotifyToDismiss), name: .addDiaryDismiss, object: nil)

    }

    //adjust tableview height to just above the keyboard
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

    @objc func onNotifyToDismiss() {
        dismiss(animated: false, completion: nil)
        self.presentingViewController?.dismiss(animated: true, completion: nil)
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
        //perform search
        APIService.instance.getFoodSearchDetailResult(foodId: suggestions[indexPath.row].id) { (foodInformation) in

            if foodInformation == nil {
                //TODO show error message
                return
            }
            self.foodResults.removeAll()
            self.foodResults.append(foodInformation!)
            self.performSegue(withIdentifier: "showTextDetail", sender: self)
        }

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

extension TextSearchViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? RecognitionResultsViewController {
            dest.recordType = "text"
            dest.results = foodResults
            dest.dateTime = Date()
            dest.userFoodImage = SampleImageMapper.instance.getFoodSampleImage(foodCategory: foodResults[0].category)
        }
    }
}
