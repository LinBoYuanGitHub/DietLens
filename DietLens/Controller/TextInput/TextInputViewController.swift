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
    @IBOutlet weak var emptyView: UIView! // empty view for let user to refresh again
    @IBOutlet weak var refreshBtn: UIButton!

    //tab item for filter the result
    var filterItem = ["All", "Ingredient", "Side dish"]
    //autoComplete & textSearchResult List
    var autoCompleteTextList = [String]()
    var searchResultList = [TextSearchSuggestionEntity]()
    //    var foodResults = [FoodInfomation]()

    var selectedImageView: UIImage?
    var addFoodDate: Date?
    var selectedFoodDiary = FoodDiaryModel()
    var filterType = TextSearchFilterInterger.allType
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
        textSearchField.returnKeyType = .search
        loadRecentTextSearchResult()
    }

    override func viewWillAppear(_ animated: Bool) {
        //regist notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden), name: .UIKeyboardWillHide, object: nil)

    }

    @IBAction func refreshSearch(_ sender: Any) {
        performTextSearch()
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
//        if Double(Date().timeIntervalSince(lastSearchTime)) > 0.1 {
//            lastSearchTime = Date()
//            performTextSearch()
//        }
    }

    func performTextSearch() {
        if isSearching {
            APIService.instance.cancelAllRequest()
//            APIService.instance.cancelRequest(requestURL: ServerConfig.foodSearchListURL + "?category=" + String(filterType))
        }
        isSearching = true
        let searchText = textSearchField.text
        APIService.instance.getFoodSearchResult(filterType: filterType, keywords: searchText!) { (textResults) in
            if textResults == nil {
                self.searchResultList.removeAll()
                self.emptyView.isHidden = false
                self.textSearchTable.reloadData()
                return
            }
            self.emptyView.isHidden = true
            self.searchResultList = textResults!
            self.textSearchTable.reloadData()
        }
    }

    func requestForDietInformation(foodId: Int) {
        if foodId == 0 {
            return
        }
        APIService.instance.getFoodDetail(foodId: foodId) { (dietItem) in
            if dietItem == nil {
                return
            }
            var dietEntity = dietItem!
            dietEntity.recordType = RecordType.RecordByImage
            if let dest = UIStoryboard(name: "AddFoodScreen", bundle: nil).instantiateViewController(withIdentifier: "FoodInfoVC") as? FoodInfoViewController {
                dest.userFoodImage = #imageLiteral(resourceName: "dietlens_sample_background")
                dest.dietItem = dietEntity
                let parentVC = self.parent as! AddFoodViewController
                dest.isSetMealByTimeRequired = parentVC.isSetMealByTimeRequired
                if let navigator = self.navigationController {
                    //clear controller to Bottom & add foodCalendar Controller
                    navigator.pushViewController(dest, animated: true)
                }
            }
        }
    }

}

//block to handle textSearchResult&autoComplete dataSource
extension TextInputViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        requestForDietInformation(foodId: textSearchEntity.id)
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
        performTextSearch()
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
        filterType = matchFilterType(index: indexPath.row)
        let destX = collectionView.cellForItem(at: indexPath)?.center.x
        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.0, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.animationView.center.x = destX!
        }) { (_) in
//            self.textSearchTable.reloadData()
            if self.textSearchField.text != ""{//search when no empty
                self.performTextSearch()
            }
        }
    }

    func matchFilterType(index: Int) -> Int {
        if index == 0 {
            return TextSearchFilterInterger.allType
        } else if index == 1 {
            return TextSearchFilterInterger.ingredientType
        } else if index == 2 {
            return TextSearchFilterInterger.sideDish
        }
        return 0// return default search,but type not found
    }

}
