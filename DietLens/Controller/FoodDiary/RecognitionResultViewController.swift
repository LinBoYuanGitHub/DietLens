//
//  RecognitionResultViewController.swift
//  DietLens
//
//  Created by linby on 10/04/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
import Reachability
import FirebaseAnalytics

class RecognitionResultViewController: BaseViewController {

    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var foodCategory: UICollectionView!
    @IBOutlet weak var foodOptionTable: UITableView!
    @IBOutlet weak var textSearchFloatingBtn: UIButton!
    @IBOutlet weak var animationView: UIView!

    //index & tracking data
    var categoryIndex = 0

    //view controller passing data
    var cameraImage: UIImage?
    var imageKey: String?
    var recordDate: Date = Date()
    var isSetMealByTimeRequired = false
    var mealType: String?
    var recordType: String?

    //dataSource
    var foodCategoryList = [DisplayFoodCategory]()
    var selectedFoodInfo = DisplayFoodInfo()

    var previousOffset: CGFloat = CGFloat(0)

    override func viewDidLoad() {
        foodImage.image = cameraImage
        foodOptionTable.delegate = self
        foodOptionTable.dataSource = self
        //add footerView
        let footerView = UIView()
        let seperatorLine = UIView()
        seperatorLine.frame = CGRect(x: 16, y: 0, width: foodOptionTable.fs_width, height: 0.5)
        seperatorLine.backgroundColor = UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1)
        footerView.addSubview(seperatorLine)
        footerView.fs_height = 60
        foodOptionTable.tableFooterView = footerView
        //food category delegate
        foodCategory.delegate = self
        foodCategory.dataSource = self
        //analytic screen name
        Analytics.setScreenName("ImageResultPage", screenClass: "RecognitionResultViewController")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

    @IBAction func toTextSearchPage(_ sender: Any) {
//        performSegue(withIdentifier: "toTextSearchPage", sender: nil)
        if let dest = UIStoryboard(name: "AddFoodScreen", bundle: nil).instantiateViewController(withIdentifier: "textInputVC") as? TextInputViewController {
            dest.cameraImage = cameraImage
            dest.imageKey = self.imageKey
            dest.isSearchMoreFlow = true
            dest.shouldShowCancel = true
            //mealTime & mealType
            dest.mealType = self.mealType!
            dest.isSetMealByTimeRequired = self.isSetMealByTimeRequired
            dest.addFoodDate = recordDate
            if let navigator = self.navigationController {
                //clear controller to Bottom & add foodCalendar Controller
                navigator.pushViewController(dest, animated: true)
            }
            //#Google Analytic part
            Analytics.logEvent(StringConstants.FireBaseAnalytic.ImageResultClickSearchMoreButton, parameters: [StringConstants.FireBaseAnalytic.Parameter.MealTime: mealType])
            //trigger search more
            Analytics.logEvent(StringConstants.FireBaseAnalytic.SearchMoreFlag, parameters: nil)
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.isSearchMoreTriggered = true
            }
        }
    }

    @IBAction func onBackPressed(_ sender: Any) {
         self.navigationController?.popViewController(animated: true)
        //#Google Analytic part
        Analytics.logEvent(StringConstants.FireBaseAnalytic.ImageResultBack, parameters: nil)
    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let navVC = segue.destination as? UINavigationController
//        if let dest = navVC?.viewControllers.first as? FoodInfoViewController {
//            dest.userFoodImage = cameraImage
//            dest.isAccumulatedDiary = false
//            dest.imageKey = imageKey!
//            dest.foodId = selectedFoodInfo.id
//        }
//    }

    func requestForDietInformation(foodId: Int) {
        if Reachability()!.connection == .none {
            let storyboard = UIStoryboard(name: "AddFoodScreen", bundle: nil)
            if let noInternetAlert =  storyboard.instantiateViewController(withIdentifier: "ConfirmationDialogVC") as? ConfirmDialogViewController {
                noInternetAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                noInternetAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                present(noInternetAlert, animated: true, completion: nil)
            }
            return
        }
        if foodId == 0 {
            return
        }
//        AlertMessageHelper.showLoadingDialog(targetController: self)
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        delegate.showLoadingDialog()
        APIService.instance.getFoodDetail(foodId: foodId) { (dietItem) in
            delegate.dismissLoadingDialog()
            if dietItem == nil {
                return
            }
            let entity = dietItem!
            if entity.isMixFood {
                self.redirectToFoodDiaryPage()
                return
            }
            entity.recordType = self.recordType ?? RecognitionInteger.recognition
            //set as new foodDiary entity
            FoodDiaryDataManager.instance.foodDiaryEntity = FoodDiaryEntity()
            if let dest = UIStoryboard(name: "AddFoodScreen", bundle: nil).instantiateViewController(withIdentifier: "FoodInfoVC") as? FoodInfoViewController {
                dest.userFoodImage = self.cameraImage
                dest.recordType = entity.recordType
                dest.imageKey = self.imageKey
                dest.dietItem = entity
                //mealTime & mealType
                FoodDiaryDataManager.instance.foodDiaryEntity.mealTime = DateUtil.normalDateToString(date: self.recordDate)
                dest.isSetMealByTimeRequired = self.isSetMealByTimeRequired
                dest.recordDate = self.recordDate
                FoodDiaryDataManager.instance.foodDiaryEntity.mealType = self.mealType!
                if let navigator = self.navigationController {
                    //clear controller to Bottom & add foodCalendar Controller
                    navigator.pushViewController(dest, animated: true)
                }
            }
        }
    }

}

extension RecognitionResultViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodCategoryList[categoryIndex].subcateFoodList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity = foodCategoryList[categoryIndex].subcateFoodList[indexPath.row]
        if entity.location.isEmpty && entity.stall.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "recognitonResultCell") as? RecognitionResultTableCell
            let calorieValue = String(Int(entity.calories))+StringConstants.UIString.calorieUnit
            cell?.setUpCell(foodName: entity.displayName, imageUrl: entity.exampleImgUrl, calorieText: calorieValue, unitText: entity.unit)
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "recognitonLocationResultCell") as? RecognitonLocationResultCell
            let calorieValue = String(Int(entity.calories))+StringConstants.UIString.calorieUnit
            cell?.setUpCell(foodName: entity.displayName, imageUrl: entity.exampleImgUrl, calorieText: calorieValue, locationText: entity.location)
            return cell!
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //jump to selected foodItem add FoodPage
        selectedFoodInfo = foodCategoryList[categoryIndex].subcateFoodList[indexPath.row]
        requestForDietInformation(foodId: selectedFoodInfo.id)
        //# Firebase Analytic log
        Analytics.logEvent(StringConstants.FireBaseAnalytic.ImageResultSelectFoodItem, parameters: [StringConstants.FireBaseAnalytic.Parameter.MealTime: mealType, "rank": indexPath.row])
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if appDelegate.isImageCaptureTriggered {
                Analytics.logEvent(StringConstants.FireBaseAnalytic.ImageSelectFlag, parameters: nil)
                appDelegate.isImageCaptureTriggered = false // set flag to false when selection trigger once
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }

    func redirectToFoodDiaryPage() {
        //request the mix veg API then to FoodDiaryVC
        guard let appDelegate = UIApplication.shared.delegate else {
            return
        }
        APIService.instance.postForMixVegResults(imageKey: imageKey!) { (foodDiaryEntity) in
            if foodDiaryEntity == nil {
                return
            }
            if let dest = UIStoryboard(name: "AddFoodScreen", bundle: nil).instantiateViewController(withIdentifier: "FoodDiaryVC") as? FoodDiaryViewController {
                dest.userFoodImage = self.cameraImage
                dest.imageKey = self.imageKey
                dest.isMixVeg = true
                dest.isUpdate = false
                dest.recordDate = self.recordDate
                //put the mix veg foodDiary into data manager
                FoodDiaryDataManager.instance.foodDiaryEntity = foodDiaryEntity!
                //mealTime & mealType
                FoodDiaryDataManager.instance.foodDiaryEntity.mealTime = DateUtil.normalDateToString(date: self.recordDate)
                dest.isSetMealByTimeRequired = self.isSetMealByTimeRequired
                FoodDiaryDataManager.instance.foodDiaryEntity.mealType = self.mealType!
                if let navigator = self.navigationController {
                    //clear controller to Bottom & add foodCalendar Controller
                    navigator.pushViewController(dest, animated: true)
                }
            }
        }

    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //#google analytic log part
//        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
//            if appDelegate.isImageCaptureTriggered {
//                Analytics.logEvent(StringConstants.FireBaseAnalytic.ImageResultScrollFoodItem, parameters: [
//                    StringConstants.FireBaseAnalytic.Parameter.MealTime: mealType
//                ])
//            }
//        }

    }

}

extension RecognitionResultViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return foodCategoryList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "foodCateogryCell", for: indexPath) as? FoodCategoryCollectionCell {
            cell.setUpCell(categoryName: foodCategoryList[indexPath.row].subcatName, categoryImageURL: foodCategoryList[indexPath.row].subcatImageUrl)
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //switch tab to show foodList
        categoryIndex = indexPath.row
        //move indicator to selected item
        let destX = (collectionView.cellForItem(at: indexPath)?.center.x)! - foodCategory.contentOffset.x
        UIView.animate(withDuration: 0.2) {
            self.animationView.center.x = destX
        }
        //table reload data
        foodOptionTable.reloadData()
    }

}
