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

    @IBOutlet weak var textSearchField: DesignableUITextField!
    @IBOutlet weak var textSearchFilterView: UICollectionView!
    @IBOutlet weak var textSearchTable: UITableView!
    @IBOutlet weak var animationView: UIView!  //for the selected barItem underline effort
    //tab item for filter the result
    var filterItem = ["All", "Ingredient", "Side dish"]
    //autoComplete & textSearchResult List
    var autoCompleteTextList = [String]()
    var searchResultList = [TextSearchSuggestionEntity]()
    //    var foodResults = [FoodInfomation]()

    var selectedImageView: UIImage?
    var addFoodDate: Date?
    var selectedFoodDiary = FoodDiaryModel()
    var currentInputStatus = TextInputStatus.autoComplete

    var isSearching = false
    private var lastSearchTime = Date()
    //passed parameter
    var cameraImage: UIImage?

    //enum for textSearch status
    enum TextInputStatus {
        case autoComplete
        case textSearchResult
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textSearchField.delegate = self
        textSearchTable.delegate = self
        textSearchTable.dataSource = self
        textSearchFilterView.delegate = self
        textSearchFilterView.dataSource = self
        loadRecentTextSearchResult()
    }

    override func viewWillAppear(_ animated: Bool) {
        //regist notification
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
        textSearchTable.contentInset = contentInsets
        textSearchTable.scrollIndicatorInsets = textSearchTable.contentInset
    }

    @objc func keyboardWillBeHidden () {
        textSearchTable.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }

    //GoodToHave: local storage to display recent search top2 item
    func loadRecentTextSearchResult() {
        //        historyDiaryList = FoodDiaryDBOperation.instance.getRecentAddedFoodDiary(limit: 3)
        textSearchTable.reloadData()
    }

    @IBAction func textFieldChanged(_ sender: UITextField) {
        //load suggestion from net, set time
        currentInputStatus = .autoComplete
        if Double(Date().timeIntervalSince(lastSearchTime)) > 0.1 {
            lastSearchTime = Date()
            performTextSearch()
        }
    }

    func performTextSearch() {
        if isSearching {
            APIService.instance.cancelRequest(requestURL: ServerConfig.foodSearchAutocompleteURL)
        }
        isSearching = true
        let searchText = textSearchField.text
        APIService.instance.getFoodSearchResult(keywords: searchText!) { (textResults) in
            self.searchResultList = textResults!
            self.textSearchTable.reloadData()
        }
//        APIService.instance.autoCompleteText(keywords: autoCompleteText!) { (textResults) in
//            self.isSearching = false
//            if textResults != nil {
//                self.autoCompleteTextList = textResults!
//                self.textSearchTable.reloadData()
//            }
//        }
    }

}

//block to handle textSearchResult&autoComplete dataSource
extension TextInputViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if currentInputStatus == .autoComplete {
//            return autoCompleteTextList.count
//        }
        return searchResultList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //fill in tableview
        //        if currentInputStatus == .autoComplete {
        //            guard let cell = tableView.dequeueReusableCell(withIdentifier: "autoCompleteCell") as? AutoCompleteCell else {
        //                return UITableViewCell()
        //            }
        //            let searchText = autoCompleteTextList[indexPath.row]
        //            cell.setUpCell(text: searchText)
        //            //cell to adapt the autoComplete text
        //            return cell
        //        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "textSearchCell") as? SearchResultCell else {
            return UITableViewCell()
        }
        let result  = searchResultList[indexPath.row]
        //cell to adapt the searchResult
        cell.setUpCell(textResultEntity: result)
        return cell
    }

}

//block to handle tableCell ui attribute for textSearchResult&autoComplete
extension TextInputViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //loading to get food text search detail
        let textSearchEntity = searchResultList[indexPath.row]
        APIService.instance.getFoodDetail(foodId: textSearchEntity.id, completion: { (foodInfoModel) in
            if foodInfoModel == nil {
                return
            }
            if let dest = UIStoryboard(name: "AddFoodScreen", bundle: nil).instantiateViewController(withIdentifier: "FoodInfoVC") as? FoodInfoViewController {
                dest.foodInfoModel = foodInfoModel!
                dest.isAccumulatedDiary = true
                dest.foodId = Int((foodInfoModel?.foodId)!)
                if let navigator = self.navigationController {
                    navigator.pushViewController(dest, animated: true)
                }
            }
        })
        //        selectedFoodDiary = historyDiaryList[indexPath.row]
        // Row selected, so set textField to relevant value, hide tableView
        //calculation for individual nutrition
        //        selectedImageView = (tableView.cellForRow(at: indexPath) as! HistoryFoodDiaryCell).foodDiaryImage.image
        //perform segue
        //        performSegue(withIdentifier: "historyToResult", sender: self)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.textSearchTable {
            return 60
        }
        return 0
    }
}

extension TextInputViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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

extension TextInputViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //All,Ingredient,SideDish
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //UILabel with underLine
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textSearchCollectionCell", for: indexPath) as? CollectionTextFilterCell {
            cell.setUpCell(filterText: filterItem[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //switch collectonView underline, refresh list
        let destX = collectionView.cellForItem(at: indexPath)?.center.x
        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.0, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.animationView.center.x = destX!
        }) { (_) in

        }
    }

}
