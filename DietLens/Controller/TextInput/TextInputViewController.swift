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

class TextInputViewController: UIViewController {

    @IBOutlet weak var textSearchField: DesignableUITextField!
    @IBOutlet weak var textSearchFilterView: UICollectionView!
    @IBOutlet weak var textSearchTable: UITableView!
    @IBOutlet weak var animationView: UIView!  //for the selected barItem underline effort
    @IBOutlet weak var emptyView: UIView! // empty view for let user to refresh again
    @IBOutlet weak var refreshBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var textFieldTrailing: NSLayoutConstraint!
    @IBOutlet weak var textFieldTop: NSLayoutConstraint!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var emptyResultView: UIView!
    @IBOutlet weak var animationViewLeading: NSLayoutConstraint!

    //indicator component
//    let activityIndicator:NVActivityIndicatorView?

    //tab item for filter the result
//    var filterItem = ["All", "Ingredient", "Side dish"]
    var filterItem = ["All", "Nus Canteen"]
    //autoComplete & textSearchResult List
    var autoCompleteTextList = [String]()
    var searchResultList = [TextSearchSuggestionEntity]()
    //    var foodResults = [FoodInfomation]()

    var selectedImageView: UIImage?
    var selectedFoodDiary = FoodDiaryModel()
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

    var shouldShowCancel: Bool = false
    var nextPageLink: String = ""

    var isLoading = false

    //location service
    let locationManager = CLLocationManager()
    var latitude = 0.0
    var longitude = 0.0

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
        loadRecentTextSearchResult()
        if shouldShowCancel {
            showCancelBtn()
        } else {
            hideCancelBtn()
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
    }

    @objc func handleTap() {
        let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "feedbackVC")
        self.present(dest, animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        //regist notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden), name: .UIKeyboardWillHide, object: nil)
        //set animation view position
        self.animationViewLeading.constant = 50
    }

    override func viewDidAppear(_ animated: Bool) {
        textSearchField.becomeFirstResponder()
    }

    @IBAction func refreshSearch(_ sender: Any) {
        performTextSearch()
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
        }
        isSearching = true
        let searchText = textSearchField.text
        //show loading indicator & create current search result
        self.loadingView.alpha = 1
        self.searchResultList.removeAll()
        self.textSearchTable.reloadData()
        //request for new data
        APIService.instance.getFoodSearchResult(filterType: filterType, keywords: searchText!, latitude: latitude, longitude: longitude, completion: { (textResults) in
            self.loadingView.alpha = 0
            DispatchQueue.main.async {
                self.textSearchTable.setContentOffset(.zero, animated: true)//scroll to top
            }
            if textResults == nil {
                self.emptyView.isHidden = false
                self.textSearchTable.reloadData()
                return
            }
            if textResults?.count == 0 {
                self.emptyResultView.isHidden = false
            } else {
                self.emptyResultView.isHidden = true
            }
            self.emptyView.isHidden = true
            self.searchResultList = textResults!
            self.textSearchTable.reloadData()
        }) { (nextPageLink) in
            self.nextPageLink = nextPageLink!
        }
    }

    func requestForDietInformation(foodEntity: TextSearchSuggestionEntity) {
        if foodEntity.id == 0 {
            return
        }
        AlertMessageHelper.showLoadingDialog(targetController: self)
        APIService.instance.getFoodDetail(foodId: foodEntity.id) { (dietItem) in
            AlertMessageHelper.dismissLoadingDialog(targetController: self) {
                if dietItem == nil {
                    return
                }
                var dietEntity = dietItem!
                if dietItem?.portionInfo.count != 0 {
                    dietEntity.displayUnit = (dietItem?.portionInfo[0].sizeUnit)!
                }
                if self.shouldShowCancel {
                    dietEntity.recordType = RecognitionInteger.additionText
                } else {
                    dietEntity.recordType = RecognitionInteger.text
                }
                if let dest = UIStoryboard(name: "AddFoodScreen", bundle: nil).instantiateViewController(withIdentifier: "FoodInfoVC") as? FoodInfoViewController {
                    let imageUrl = foodEntity.expImagePath
                    dest.imageUrl = imageUrl
                    dest.userFoodImage = self.cameraImage
                    dest.imageKey = self.imageKey
                    if self.shouldShowCancel {
                        dest.recordType = RecognitionInteger.additionText
                        dest.shouldShowMealBar = false
                    } else {
                        dest.recordType = dietEntity.recordType
                    }
                    dest.dietItem = dietEntity
                    //mealType & mealTime
                    dest.isSetMealByTimeRequired = self.isSetMealByTimeRequired
                    dest.foodDiaryEntity.mealTime = DateUtil.normalDateToString(date: self.addFoodDate)
                    dest.foodDiaryEntity.mealType = self.mealType
                    if let navigator = self.navigationController {
                        navigator.pushViewController(dest, animated: true)
                    }
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
        requestForDietInformation(foodEntity: textSearchEntity)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.textSearchTable {
            return 52
        }
        return 0
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let  height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            if nextPageLink == "" || isLoading {
                //last page
                return
            }
            //show loading indicator
//            let xAxis  = self.view.center.x
//            let yAxis = self.view.center.y
//            let frame = CGRect(x: xAxis, y: yAxis, width: 50, height: 50)
            textSearchTable.tableFooterView?.isHidden = false
            self.isLoading = true
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
        //All,NUS Canteen
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.size.width/2, height: 50)
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
            self.animationViewLeading.constant = destX! - CGFloat(40)
//            self.animationView.center.x = destX!
        }) { (_) in
//            self.textSearchTable.reloadData()
            if self.textSearchField.text != ""{ //search when no empty
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
