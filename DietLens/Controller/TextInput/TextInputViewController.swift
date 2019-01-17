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
import NVActivityIndicatorView
import CoreLocation
import Reachability
import FirebaseAnalytics

class TextInputViewController: BaseViewController {

    @IBOutlet weak var textSearchField: DesignableUITextField!
    @IBOutlet weak var textSearchFilterView: UICollectionView!
    @IBOutlet weak var textSearchTable: UITableView!
    @IBOutlet weak var animationView: UIView!  //for the selected barItem underline effort
    @IBOutlet weak var emptyView: UIView! // empty view for let user to refresh again
    @IBOutlet weak var refreshBtn: UIButton!
    @IBOutlet weak var emptyViewLabel: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var textFieldTrailing: NSLayoutConstraint!
    @IBOutlet weak var textFieldTop: NSLayoutConstraint!
    @IBOutlet weak var searchLoadingView: UIView!
    @IBOutlet weak var emptyResultView: UIView!
    @IBOutlet weak var animationViewLeading: NSLayoutConstraint!

    //tab item for filter the result
    var filterItem = [StringConstants.UIString.FitlerPopular, StringConstants.UIString.FilterRecent, StringConstants.UIString.FilterFavorite]
    //display tableView data
    var searchResultList = [TextSearchSuggestionEntity]()
    var popularFoodList = [TextSearchSuggestionEntity]()
    var recentFoodList = [TextSearchSuggestionEntity]()
    var favoriteFoodList = [TextSearchSuggestionEntity]()
    //UI component
    var selectedImageView: UIImage?
    var filterType = TextSearchFilterInterger.allType
    var isSearching = false
    private var lastSearchTime = Date()
    //passed parameter
    var cameraImage: UIImage?
    var imageKey: String?
    //mealTime & mealType
    var addFoodDate = Date()
    var mealType: String = StringConstants.MealString.breakfast
    var isSetMealByTimeRequired = true

    var isSearchMoreFlow: Bool = false
    var shouldShowCancel: Bool = false
    var nextPageLink: String = ""

    var isLoading = false
    var isInTextSearch = false

    @IBOutlet weak var tableTopConstants: NSLayoutConstraint!

    //location service
    let locationManager = CLLocationManager()
    var latitude = 0.0
    var longitude = 0.0

    var currentSelectionPos = 0
    let searchCacheLRU = TextSuggestionCacheLRU(capacity: 6)

    //enum for textSearch status
    enum TextInputStatus {
        case autoComplete
        case textSearchResult
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //set status bar appearance
        setNeedsStatusBarAppearanceUpdate()
        textSearchField.delegate = self
        textSearchField.keyboardType = .asciiCapable
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.textSearchField.frame.height))
        textSearchField.leftView = paddingView
        textSearchField.leftViewMode = UITextFieldViewMode.always

        textSearchTable.delegate = self
        textSearchTable.dataSource = self
        textSearchFilterView.delegate = self
        textSearchFilterView.dataSource = self
        textSearchField.returnKeyType = .search
        textSearchTable.reloadData()
        if shouldShowCancel {
            showCancelBtn()
        } else {
            hideCancelBtn()
            //trigger text search
            Analytics.logEvent(StringConstants.FireBaseAnalytic.TextViewFlag, parameters: nil)
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.isTextInputTriggered = true
            }
        }
        //set loading footerView
        textSearchTable.tableFooterView = LoadingFooterView(frame: CGRect(x: 0, y: 0, width: textSearchTable.frame.size.width, height: 52))
        textSearchTable.tableFooterView?.isHidden = true
        //set up location manager
        if CLLocationManager.locationServicesEnabled() {
            enableLocationServices()
        } else {
            print("Location services are not enabled")
        }
        self.emptyResultView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        //set animation view position
        self.animationViewLeading.constant = 16
        //load popular list
        getPopurlarFoodLists()
        //analytic screen name
        Analytics.setScreenName("TextPage", screenClass: "TextInputViewController")
    }

    @objc func handleTap() {
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationController?.navigationBar.isHidden = true
        //only refresh cache data
        if (textSearchField.text?.isEmpty)! && currentSelectionPos != 0 {
            onFilterSelect(currentSelection: currentSelectionPos)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        //set event for favFood empty label jump
        self.emptyView.addGestureRecognizer( UITapGestureRecognizer(target: self, action: #selector(redirectToFavoriteFoodPage)))
    }

    @IBAction func refreshSearch(_ sender: Any) {
        if (textSearchField.text?.isEmpty)! {
            onFilterSelect(currentSelection: currentSelectionPos)
        } else {
            performTextSearch()
        }

    }

    func showCancelBtn() {
        cancelBtn.isHidden = false
        textFieldTrailing.constant = 74
        textFieldTop.constant = 10
    }

    func hideCancelBtn() {
        cancelBtn.isHidden = true
        textFieldTrailing.constant = 16
        textFieldTop.constant =  10
    }

    @IBAction func onCancelBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        //#Google Analytic part
        Analytics.logEvent(StringConstants.FireBaseAnalytic.SearchMoreClickBack, parameters: nil)
    }

    //GoodToHave: local storage to display recent search top2 item
    func getPopurlarFoodLists() {
        if isSetMealByTimeRequired {
            self.mealType = getCorrectMealType()
        }
        APIService.instance.getFoodSearchPopularity(mealtime: mealType.lowercased(), completion: { (textResults) in
            guard let results = textResults else { // excpetion + cancelled
                self.emptyView.isHidden = false
                self.textSearchTable.isHidden = true
                return
            }
            self.emptyResultView.isHidden = true
            self.emptyView.isHidden = true
            self.textSearchTable.isHidden = false
            self.popularFoodList = results
            self.textSearchTable.reloadData()
        }) { (nextPageLink) in
            self.nextPageLink = nextPageLink!
        }
    }

    func getFavouriteFoods() {
        APIService.instance.getFavouriteFoodList(completion: { (textResults) in
            if textResults == nil {
                self.emptyView.isHidden = false
                self.textSearchTable.isHidden = true
                return
            } else if textResults?.count == 0 {
                self.textSearchTable.isHidden = true
                self.emptyViewLabel.text = "click here to select your favorite food"
                self.refreshBtn.isHidden = true
                self.emptyView.isHidden = false
                return
            }
            self.emptyResultView.isHidden = true
            self.emptyView.isHidden = true
            self.textSearchTable.isHidden = false
            self.favoriteFoodList = textResults!
            self.textSearchTable.reloadData()
        }, nextPageCompletion: { (nextPageLink) in
            self.nextPageLink = nextPageLink!
        })
    }

    @objc func redirectToFavoriteFoodPage() {
        if currentSelectionPos != 2 { //return when it's not at favorite food tab
            return
        }
        if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PersonalFavouriteFoodVC") as? PersonalFavouriteFoodViewController {
            if let navigator = self.navigationController {
                navigator.pushViewController(dest, animated: false)
            }
        }
    }

    func getCorrectMealType() -> String {
        let hour: Int = Calendar.current.component(.hour, from: Date())
        if hour < ConfigVariable.BreakFastEndTime && hour >= ConfigVariable.BreakFastStartTime {
            return StringConstants.MealString.breakfast
        } else if hour < ConfigVariable.LunchEndTime && hour >= ConfigVariable.LunchStartTime {
            return StringConstants.MealString.lunch
        } else if hour < ConfigVariable.DinnerEndTime && hour >= ConfigVariable.DinnerStartTime {
            return StringConstants.MealString.dinner
        } else {
            return StringConstants.MealString.snack
        }
    }

    @IBAction func textFieldChanged(_ sender: UITextField) {
        //textFilter hide/show control
        self.textSearchTable.isHidden = false
        if (sender.text?.isEmpty)! {
            tableTopConstants.constant = 50
            textSearchFilterView.isHidden = false
            animationView.isHidden = false
            self.isInTextSearch = false
            onFilterSelect(currentSelection: currentSelectionPos)
        } else {
            //load suggestion from net, set time
            tableTopConstants.constant = 0
            textSearchFilterView.isHidden = true
            animationView.isHidden = true
            self.isInTextSearch = true
            performTextSearch()
        }

    }

    func performTextSearch() {
        if Reachability()?.connection == Reachability.Connection.none && currentSelectionPos != 2 {
            self.textSearchTable.isHidden = true
            self.emptyView.isHidden = false
            return
        }
        self.emptyView.isHidden = true
        if isSearching {
            APIService.instance.cancelAllRequest()
            print("cancel text search \(textSearchField.text ?? "")")
        }
        isSearching = true
        let searchText = textSearchField.text
        if (searchText?.isEmpty)! {
            return
        }
        //request for new data
        APIService.instance.getFoodSearchResult(filterType: filterType, keywords: searchText!, latitude: latitude, longitude: longitude, completion: { [weak self] (textResults) in
            guard let service = self else {
                return
            }
            service.isSearching = false
            if textResults == nil {
                return
            }
            if textResults?.count == 0 {
                service.emptyResultView.isHidden = false
            } else {
                service.emptyResultView.isHidden = true
                if service.searchResultList.count != 0 {
                    DispatchQueue.main.async {
                        service.textSearchTable.reloadData()
                        let indexPath = IndexPath(row: 0, section: 0)
                        service.textSearchTable.scrollToRow(at: indexPath, at: .bottom, animated: false)
                    }
                }
            }
            service.emptyView.isHidden = true
            service.searchResultList = textResults!
            service.textSearchTable.reloadData()
        }) { (nextPageLink) in
            self.nextPageLink = nextPageLink!
        }
    }

    func requestForDietInformation(foodEntity: TextSearchSuggestionEntity) {
        if Reachability()!.connection == .none {
            let storyboard = UIStoryboard(name: "AddFoodScreen", bundle: nil)
            if let noInternetAlert =  storyboard.instantiateViewController(withIdentifier: "ConfirmationDialogVC") as? ConfirmDialogViewController {
                noInternetAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                noInternetAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                present(noInternetAlert, animated: true, completion: nil)
            }
            return
        }
        if foodEntity.id == 0 {
            return
        }
        //request Food info
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        appdelegate.showLoadingDialog()
        APIService.instance.getFoodDetail(foodId: foodEntity.id) { (dietItem) in
            appdelegate.dismissLoadingDialog()
            if dietItem == nil {
                return
            }
            //save select Item to lruCache
            self.searchCacheLRU.setValue(foodEntity, for: foodEntity.id)
            //dietItem operation
            let dietEntity = dietItem!
            if dietItem?.portionInfo.count != 0 {
                dietEntity.displayUnit = (dietItem?.portionInfo[0].sizeUnit)!
            }
            if self.isSearchMoreFlow {
                dietEntity.recordType = RecognitionInteger.additionText
            } else {
                dietEntity.recordType = RecognitionInteger.text
            }
            //set as new foodDiary entity
            if !self.isSearchMoreFlow {
                FoodDiaryDataManager.instance.foodDiaryEntity = FoodDiaryEntity()
            }
            //mealType & mealTime
            if FoodDiaryDataManager.instance.foodDiaryEntity.mealType.isEmpty {
                FoodDiaryDataManager.instance.foodDiaryEntity.mealType = self.mealType
            }
            if FoodDiaryDataManager.instance.foodDiaryEntity.mealTime.isEmpty {
                FoodDiaryDataManager.instance.foodDiaryEntity.mealTime = DateUtil.normalDateToString(date: self.addFoodDate)
            }
            if let dest = UIStoryboard(name: "AddFoodScreen", bundle: nil).instantiateViewController(withIdentifier: "FoodInfoVC") as? FoodInfoViewController {
                let imageUrl = foodEntity.expImagePath
                dest.imageUrl = imageUrl
                dest.userFoodImage = self.cameraImage
                dest.imageKey = self.imageKey
                dest.recordDate = self.addFoodDate
                dest.dietItem = dietEntity
                if self.isSearchMoreFlow {
                    dest.recordType = RecognitionInteger.additionText
                    dest.shouldShowMealBar = false
                } else {
                    dest.recordType = dietEntity.recordType
                }
                dest.isSetMealByTimeRequired = self.isSetMealByTimeRequired
                if let navigator = self.navigationController {
                    navigator.pushViewController(dest, animated: true)
                }
            }
        }
    }

    func onFilterSelect(currentSelection: Int) {
//        APIService.instance.cancelAllRequest()
        self.textSearchTable.reloadData()
        if currentSelection == 0 {
            self.getPopurlarFoodLists()
        } else if currentSelection == 1 {
            //load recent search result
            self.textSearchTable.isHidden = false
            self.recentFoodList = self.searchCacheLRU.getAllValue()
            self.textSearchTable.reloadData()
        } else if currentSelection == 2 {
            self.getFavouriteFoods()
        }
    }

}

//block to handle textSearchResult&autoComplete dataSource
extension TextInputViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isInTextSearch {
            return searchResultList.count
        } else if currentSelectionPos == 0 {
            return popularFoodList.count
        } else if currentSelectionPos == 1 {
            return recentFoodList.count
        } else {
            return favoriteFoodList.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var result = TextSearchSuggestionEntity()
        if isInTextSearch {
            if indexPath.row < searchResultList.count {
                result = searchResultList[indexPath.row]
            }
        } else if currentSelectionPos == 0 {
            result = popularFoodList[indexPath.row]
        } else if currentSelectionPos == 1 {
            result = recentFoodList[indexPath.row]
        } else {
            result = favoriteFoodList[indexPath.row]
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "textSearchCell") as? SearchResultCell else {
            return UITableViewCell()
        }
        cell.setUpCell(textResultEntity: result)
        return cell
    }

}

//block to handle tableCell ui attribute for textSearchResult&autoComplete
extension TextInputViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //loading to get food text search detail
        var textSearchEntity = TextSearchSuggestionEntity()
        if isInTextSearch {
            textSearchEntity = searchResultList[indexPath.row]
        } else if currentSelectionPos == 0 {
            textSearchEntity = popularFoodList[indexPath.row]
        } else if currentSelectionPos == 1 {
            textSearchEntity = recentFoodList[indexPath.row]
        } else {
            textSearchEntity = favoriteFoodList[indexPath.row]
        }
        requestForDietInformation(foodEntity: textSearchEntity)
        //# Firebase Analytic log
        Analytics.logEvent(StringConstants.FireBaseAnalytic.TextResultSelectFoodItem, parameters: [StringConstants.FireBaseAnalytic.Parameter.MealTime: mealType, "rank": indexPath.row])
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        if isSearchMoreFlow { //search more flow
            if appDelegate.isSearchMoreTriggered {
                appDelegate.isSearchMoreTriggered = false
                Analytics.logEvent(StringConstants.FireBaseAnalytic.SearchMoreSelectFlag, parameters: nil)
            }
        } else {
            if appDelegate.isTextInputTriggered {
                appDelegate.isTextInputTriggered = false
                Analytics.logEvent(StringConstants.FireBaseAnalytic.TextSelectFlag, parameters: nil)
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.textSearchTable {
            return 70
        }
        return 0
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //dismiss keyboard when scroller in accelerate status
        if scrollView.isDecelerating {
            view.endEditing(true)
        }
        //scroll part of code
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            if nextPageLink == "" || isLoading || currentSelectionPos == 1 { //loading & no nextPage & at recentPage
                //last page
                return
            }
            //show loading indicator
            textSearchTable.tableFooterView?.isHidden = false
            self.isLoading = true
            //API pagination
            if !(self.textSearchField.text?.isEmpty)! {
                APIService.instance.getFoodSearchResult(requestUrl: self.nextPageLink, keywords: textSearchField.text!, latitude: latitude, longitude: longitude, completion: { (resultList) in
                    self.textSearchTable.tableFooterView?.isHidden = true
                    self.isLoading = false
                    if resultList == nil {
                        return
                    }
                    self.searchResultList.append(contentsOf: resultList!)
                    self.textSearchTable.reloadData()
                }) { (nextPageLink) in
                    if nextPageLink == nil {
                        // last page
                        self.nextPageLink = ""
                    } else {
                        self.nextPageLink = nextPageLink!
                    }
                }
            } else {
                switch self.currentSelectionPos {
                case 0:
                    APIService.instance.getFoodSearchPopularity(requestUrl: self.nextPageLink, mealtime: mealType, completion: { (resultList) in
                        self.textSearchTable.tableFooterView?.isHidden = true
                        self.isLoading = false
                        if resultList == nil {
                            return
                        }
                        self.popularFoodList.append(contentsOf: resultList!)
                        self.textSearchTable.reloadData()
                    }, nextPageCompletion: { (nextPageLink) in
                        if nextPageLink == nil {
                            // last page
                            self.nextPageLink = ""
                        } else {
                            self.nextPageLink = nextPageLink!
                        }
                    })
                case 1:
                    break
                case 2:
                    APIService.instance.getFavouriteFoodList(requestUrl: self.nextPageLink, completion: { (resultList) in
                        self.textSearchTable.tableFooterView?.isHidden = true
                        self.isLoading = false
                        if resultList == nil {
                            return
                        }
                        self.favoriteFoodList.append(contentsOf: resultList!)
                        self.textSearchTable.reloadData()
                    }) { (nextPageLink) in
                        if nextPageLink == nil {
                            self.nextPageLink = ""
                        } else {
                            self.nextPageLink = nextPageLink!
                        }
                    }
                default:
                    break
                }
            }
        }
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

}

extension TextInputViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //Recent,Frequent,Favorite
        return filterItem.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.view.frame.size.width-32)/CGFloat(filterItem.count), height: 50)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //UILabel with underLine
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textSearchCollectionCell", for: indexPath) as? CollectionTextSearchFilterCell {
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
            self.animationViewLeading.constant = destX! - CGFloat(40)
        }) { (_) in
            self.emptyView.isHidden = true
            self.currentSelectionPos = indexPath.row
            self.onFilterSelect(currentSelection: self.currentSelectionPos)
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

    func enableLocationServices() {
        locationManager.delegate = self
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // Request when-in-use authorization initially
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        case .restricted, .denied:
            break
        case .authorizedWhenInUse:
            // Enable basic location features
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        case .authorizedAlways:
            break
        }
    }

}

extension TextInputViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.latitude = (locations.last?.coordinate.latitude)!
        self.longitude = (locations.last?.coordinate.longitude)!
        locationManager.stopUpdatingLocation()
    }
}
