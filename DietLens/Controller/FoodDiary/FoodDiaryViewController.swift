//
//  FoodDiaryViewController.swift
//  DietLens
//
//  Created by linby on 10/04/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
import Instructions
import FirebaseAnalytics

class FoodDiaryViewController: UIViewController {

    @IBOutlet weak var foodSampleImage: UIImageView!
    @IBOutlet weak var mealCollectionView: UICollectionView!
    @IBOutlet weak var foodTableView: UITableView!
    @IBOutlet weak var animationView: UIView!
    //sum nutritionPart
    @IBOutlet weak var calorieValueLabel: UILabel!
    @IBOutlet weak var proteinValueLable: UILabel!
    @IBOutlet weak var fatValueLabel: UILabel!
    @IBOutlet weak var carbohydrateLabel: UILabel!
    //table header: foodImage,mealTypeView,nutritionView
    @IBOutlet weak var addMore: UIView!

    //dataSource
    var foodDiaryInstance = FoodDiaryDataManager.instance.foodDiaryEntity
    //passing parameter
    var userFoodImage: UIImage?
    var imageKey: String?
    var isUpdate: Bool = false //from foodCalendar then update
    var isMixVeg: Bool = false //mix veg
    //mealType data
    var mealStringArray = [StringConstants.MealString.breakfast, StringConstants.MealString.lunch, StringConstants.MealString.dinner, StringConstants.MealString.snack]
    var currentMealIndex = 0
    var isSetMealByTimeRequired: Bool = false
    @IBOutlet weak var animationViewLeading: NSLayoutConstraint!
    //add coachMarks
    let coachMarksController = CoachMarksController()

    var recordDate = Date()

    override func viewDidLoad() {
        mealCollectionView.delegate = self
        mealCollectionView.dataSource = self
        foodTableView.delegate = self
        foodTableView.dataSource = self
        foodSampleImage.image = userFoodImage
        //registration for resuable nib cellItem
        mealCollectionView.register(MealTypeCollectionCell.self, forCellWithReuseIdentifier: "mealTypeCell")
        mealCollectionView.register(UINib(nibName: "MealTypeCollectionCell", bundle: nil), forCellWithReuseIdentifier: "mealTypeCell")
        mealCollectionView.isScrollEnabled = false
        initFoodInfo()
        setCorrectMealType()
        let addMoreGesture = UITapGestureRecognizer(target: self, action: #selector(onAddMoreClick))
        addMore.addGestureRecognizer(addMoreGesture)
        loadImage()
        //set instruction label dataSource
        self.coachMarksController.dataSource = self
        self.coachMarksController.overlay.color = UIColor(red: CGFloat(0), green: CGFloat(0), blue: CGFloat(0), alpha: 0.52)
        //analytic screen name
        if isUpdate {
            Analytics.setScreenName("AddFoodListPage", screenClass: "FoodDiaryViewController")
        } else {
            Analytics.setScreenName("EditFoodListPage", screenClass: "FoodDiaryViewController")
        }
    }

    func loadImage() {
        if imageKey == ""{
            self.foodSampleImage.image = #imageLiteral(resourceName: "dietlens_sample_background")
            return
        }
        self.foodSampleImage.image = #imageLiteral(resourceName: "loading_img")
        APIService.instance.qiniuImageDownload(imageKey: imageKey!) { (foodImage) in
            if foodImage == nil {
                return
            }
            self.foodSampleImage.image = foodImage
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        //move indicator to correct position
        let indexPath = IndexPath(item: currentMealIndex, section: 0)
        let destX = mealCollectionView.cellForItem(at: indexPath)?.center.x
        UIView.animate(withDuration: 0.1, delay: 0.1, usingSpringWithDamping: 0.0, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.animationViewLeading.constant = destX! + CGFloat(10)
        })
        //show markView
        let preference = UserDefaults.standard
        let showCoachMarkFlag = !preference.bool(forKey: FirstTimeFlag.isNotFirstTimeViewMixFood)
        if isMixVeg && showCoachMarkFlag {
            self.coachMarksController.start(on: self)
            preference.set(true, forKey: FirstTimeFlag.isNotFirstTimeViewMixFood)
        }
    }

    func setCorrectMealType() {
        if isSetMealByTimeRequired {
            let hour: Int = Calendar.current.component(.hour, from: Date())
            if hour < ConfigVariable.BreakFastEndTime && hour >= ConfigVariable.BreakFastStartTime {
                foodDiaryInstance.mealType = StringConstants.MealString.breakfast
                currentMealIndex = 0
                mealCollectionView.reloadData()
            } else if hour < ConfigVariable.LunchEndTime && hour >= ConfigVariable.LunchStartTime {
                foodDiaryInstance.mealType = StringConstants.MealString.lunch
                currentMealIndex = 1
                mealCollectionView.reloadData()
            } else if hour < ConfigVariable.DinnerEndTime && hour >= ConfigVariable.DinnerStartTime {
                foodDiaryInstance.mealType = StringConstants.MealString.dinner
                currentMealIndex = 2
                mealCollectionView.reloadData()
            } else {
                foodDiaryInstance.mealType = StringConstants.MealString.snack
                currentMealIndex = 3
                mealCollectionView.reloadData()
            }
        } else {
            switch foodDiaryInstance.mealType {
            case StringConstants.MealString.breakfast:
                currentMealIndex = 0
                mealCollectionView.reloadData()
            case StringConstants.MealString.lunch:
                currentMealIndex = 1
                mealCollectionView.reloadData()
            case StringConstants.MealString.dinner:
                currentMealIndex = 2
                mealCollectionView.reloadData()
            case StringConstants.MealString.snack:
                currentMealIndex = 3
                mealCollectionView.reloadData()
            default:
                break
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        //set status bar appearance
        UIApplication.shared.statusBarStyle = .default
        //navigation controller
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.title = "Meal"
        if isUpdate {
            //            self.navigationItem.rightBarButtonItem?.title = StringConstants.UIString.moreBtnText
            self.navigationItem.rightBarButtonItem?.image = UIImage(imageLiteralResourceName: "more_dots")
        } else {
            self.navigationItem.rightBarButtonItem?.title = StringConstants.UIString.saveBtnText
        }
        let textColor = UIColor(red: CGFloat(67/255), green: CGFloat(67/255), blue: CGFloat(67/255), alpha: 1.0)
        if let attributeGroup = [NSAttributedStringKey.foregroundColor: textColor, kCTFontAttributeName: UIFont(name: "PingFangSC-Regular", size: 18)!] as?  [NSAttributedStringKey: Any] {
            self.navigationController?.navigationBar.titleTextAttributes = attributeGroup
        }
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @objc func onAddMoreClick() {
        if let dest = UIStoryboard(name: "AddFoodScreen", bundle: nil).instantiateViewController(withIdentifier: "textInputVC") as? TextInputViewController {
            dest.addFoodDate = self.recordDate
            dest.isSearchMoreFlow = true
            dest.shouldShowCancel = true
            //            dest.cameraImage = cameraImage use sample Image
            if let navigator = self.navigationController {
                //clear controller to Bottom & add foodCalendar Controller
                navigator.pushViewController(dest, animated: true)
            }
        }
    }

    @IBAction func onBackPressed() {
        self.navigationController?.popViewController(animated: true)
        //#Google Analytic part
        Analytics.logEvent(StringConstants.FireBaseAnalytic.FoodListClickBack, parameters: nil)
    }

    //save(from text Search) or update foodDiary
    @IBAction func onTopRightBtnPressed(_ sender: Any) {
        NotificationCenter.default.post(name: .shouldRefreshMainPageNutrition, object: nil)
        if isUpdate {
            let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            optionMenu.view.tintColor = UIColor.ThemeColor.dietLensRed
            let deleteAction = UIAlertAction(title: StringConstants.UIString.deleteActionItem, style: .default) { (_: UIAlertAction!) in
                //delete foodDiary api flow
                APIService.instance.deleteFoodDiary(foodDiaryId: self.foodDiaryInstance.foodDiaryId, completion: { (_) in
                    //refresh the foodDiary page if it exist in the viewController stack
                    if let navigator = self.navigationController {
                        for vc in navigator.viewControllers {
                            if let homeTabVC = vc as? HomeTabViewController {
                                homeTabVC.shouldSwitchToFoodDiary = true
                                homeTabVC.foodDiarySelectedDate = self.recordDate
                            }
                        }
                    }
                    self.navigationController?.popViewController(animated: true)
                })
            }
            let updateAction = UIAlertAction(title: StringConstants.UIString.updateBtnText, style: .default) { (_: UIAlertAction!) in
                //update foodDiary api flow
                APIService.instance.updateFoodDiary(isPartialUpdate: true, foodDiary: self.foodDiaryInstance, completion: { (isSuccess, _) in
                    if isSuccess {
                        if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeTabVC") as? HomeTabViewController {
                            if let navigator = self.navigationController {
                                dest.shouldSwitchToFoodDiary = true
                                dest.foodDiarySelectedDate = self.recordDate
                                //pop to home tabPage
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                                    navigator.popToRootViewController(animated: true)
                                })
                            }
                        }

                    } else {
                        AlertMessageHelper.showMessage(targetController: self, title: "", message: "update failed")
                    }
                })
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            optionMenu.addAction(updateAction)
            optionMenu.addAction(deleteAction)
            optionMenu.addAction(cancelAction)
            self.present(optionMenu, animated: true, completion: nil)
        } else {
            guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            appdelegate.showLoadingDialog()
            APIService.instance.createFooDiary(foodDiary: foodDiaryInstance, completion: { (isSuccess) in
                appdelegate.dismissLoadingDialog()
                if isSuccess {
                    if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeTabVC") as? HomeTabViewController {
                        if let navigator = self.navigationController {
                            //pop to home tabPage
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                                dest.shouldSwitchToFoodDiary = true
                                dest.foodDiarySelectedDate = self.recordDate
                                navigator.popToRootViewController(animated: true)
                            })
                        }
                    }
                }
                //#google analytic log part
                Analytics.logEvent(StringConstants.FireBaseAnalytic.SearchMoreAddFlag, parameters: nil)
            })
        }
    }

    func initFoodInfo() {
        if imageKey != nil {//set imageKey to foodDiaryEntity
            foodDiaryInstance.imageId = self.imageKey!
        }
        calculateAccumulateFoodValue()
    }

    func calculateAccumulateFoodValue() {
        var accumulatedCalorie = 0
        var accumulatedCarbohydrate = 0.0
        var accumulatedProtein = 0.0
        var accumulatedFat = 0.0
        //get accumualted value
        for dietItem in foodDiaryInstance.dietItems {
            var ratio = dietItem.quantity
            if dietItem.portionInfo.count != 0 {
                ratio = dietItem.quantity*dietItem.portionInfo[dietItem.selectedPos].weightValue/100
            }
            accumulatedCalorie += Int(dietItem.nutritionInfo.calorie*ratio)
            accumulatedCarbohydrate += Double(dietItem.nutritionInfo.carbohydrate*ratio)
            accumulatedProtein += Double(dietItem.nutritionInfo.protein*ratio)
            accumulatedFat += Double(dietItem.nutritionInfo.fat*ratio)
        }
        let calorieStr = String(accumulatedCalorie) + StringConstants.UIString.calorieUnit
        let carbohydrateStr = String(format: "%.1f", accumulatedCarbohydrate) + StringConstants.UIString.diaryIngredientUnit
        let proteinStr =  String(format: "%.1f", accumulatedProtein) + StringConstants.UIString.diaryIngredientUnit
        let fatStr =  String(format: "%.1f", accumulatedFat) + StringConstants.UIString.diaryIngredientUnit
        //calorieValue
        let calorieText = NSMutableAttributedString.init(string: calorieStr)
        calorieText.setAttributes([NSAttributedStringKey.font: UIFont(name: "PingFangSC-Light", size: 14.0),
                                   kCTForegroundColorAttributeName as NSAttributedStringKey: UIColor.gray], range: NSRange(location: calorieStr.count - 4, length: 4))
        calorieValueLabel.attributedText = calorieText
        //carbohydrateValue
        let carbohydrateText = NSMutableAttributedString.init(string: carbohydrateStr)
        carbohydrateText.setAttributes([NSAttributedStringKey.font: UIFont(name: "PingFangSC-Light", size: 14.0),
                                        kCTForegroundColorAttributeName as NSAttributedStringKey: UIColor.gray], range: NSRange(location: carbohydrateStr.count - 1, length: 1))
        carbohydrateLabel.attributedText = carbohydrateText
        //protein
        let proteinText = NSMutableAttributedString.init(string: proteinStr)
        proteinText.setAttributes([NSAttributedStringKey.font: UIFont(name: "PingFangSC-Light", size: 14.0),
                                   kCTForegroundColorAttributeName as NSAttributedStringKey: UIColor.gray], range: NSRange(location: proteinStr.count - 1, length: 1))
        proteinValueLable.attributedText = proteinText
        //fat
        let fatText = NSMutableAttributedString.init(string: fatStr)
        fatText.setAttributes([NSAttributedStringKey.font: UIFont(name: "PingFangSC-Light", size: 14.0),
                               kCTForegroundColorAttributeName as NSAttributedStringKey: UIColor.gray], range: NSRange(location: fatStr.count - 1, length: 1))
        fatValueLabel.attributedText = fatText
    }

    //********************************************************************************************************************
    // food item CRUD part
    //********************************************************************************************************************

    //add foodDiary into item & update
    func addFoodIntoItem() {
        //asycn task for syncing server data
        if !foodDiaryInstance.foodDiaryId.isEmpty {
            APIService.instance.updateFoodDiary(isPartialUpdate: false, foodDiary: foodDiaryInstance) { (isSuccess, foodDiaryEntity)  in
                if foodDiaryEntity != nil && isSuccess {
                    //refresh foodDiaryEntity
                    self.foodDiaryInstance = foodDiaryEntity!
                } else {
                    AlertMessageHelper.showMessage(targetController: self, title: "", message: "add food item failed")
                }
            }
        }
        let indexPath = IndexPath(row: foodDiaryInstance.dietItems.count-1, section: 0)
        //refresh nutrition part
        self.calculateAccumulateFoodValue()
        //insert row animation for add food
        foodTableView.beginUpdates()
        foodTableView.insertRows(at: [indexPath], with: .automatic)
        foodTableView.endUpdates()

    }

    //update foodDiary
    func updateFoodInfoItem(row: Int) {
        let indexPath = IndexPath(row: row, section: 0)
        //refresh nutrition part
        self.calculateAccumulateFoodValue()
        //update food table
        foodTableView.reloadRows(at: [indexPath], with: .automatic)
        if !foodDiaryInstance.foodDiaryId.isEmpty && !foodDiaryInstance.dietItems[row].id.isEmpty {
            APIService.instance.updateFoodDiary(isPartialUpdate: false, foodDiary: foodDiaryInstance) { (isSuccess, _) in
                if !isSuccess {
                     AlertMessageHelper.showMessage(targetController: self, title: "", message: "update food item failed")
                }
            }
        }
    }

    //delete foodDiary
    func deleteFoodItem(row: Int) {
        if !foodDiaryInstance.foodDiaryId.isEmpty && !foodDiaryInstance.dietItems[row].id.isEmpty {
            APIService.instance.deleteFoodItem(foodDiaryId: foodDiaryInstance.foodDiaryId, foodItemId: foodDiaryInstance.dietItems[row].id) { (_) in }
        }
        self.foodDiaryInstance.dietItems.remove(at: row)
        let indexPath = IndexPath(row: row, section: 0)
        //refresh nutrition part
        self.calculateAccumulateFoodValue()
        //update food table
        foodTableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

extension FoodDiaryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mealStringArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mealTypeCell", for: indexPath) as? MealTypeCollectionCell {
            cell.setUpCell(isHightLight: false, mealStr: mealStringArray[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //change the mealType block selection
        currentMealIndex = indexPath.row
        foodDiaryInstance.mealType = mealStringArray[indexPath.row]
        //switch collection selection
        let destX = collectionView.cellForItem(at: indexPath)?.center.x
        UIView.animate(withDuration: 0.2, delay: 0.1, usingSpringWithDamping: 0.0, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.self.animationViewLeading.constant = destX! + CGFloat(10)
        })
        //set request to switch time
        APIService.instance.updateFoodDiary(isPartialUpdate: true, foodDiary: self.foodDiaryInstance, completion: { (isSuccess, _) in
            if !isSuccess {
                AlertMessageHelper.showMessage(targetController: self, title: "", message: "update meal time failed")
            }
        })
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CGFloat(70), height: CGFloat(35))
    }

}

extension FoodDiaryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodDiaryInstance.dietItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //name, portion calorie , deleteBtn
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FoodItemListCell") as? FoodItemListCell {
            let entity = foodDiaryInstance.dietItems[indexPath.row]
            cell.setUpCell(dietItem: entity)
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //request for portion data
        jumpToFoodInfoPage(index: indexPath.row)
    }

    func jumpToFoodInfoPage(index: Int) {
        //jump to foodInfo page to modify foodInfo Item
        if let dest = UIStoryboard(name: "AddFoodScreen", bundle: nil).instantiateViewController(withIdentifier: "FoodInfoVC") as? FoodInfoViewController {
            dest.imageKey = imageKey
            dest.shouldShowMealBar = false
            dest.isUpdate = true
            dest.indexFromUpdate = index
            if let navigator = self.navigationController {
                //pop all the view except HomePage
                navigator.pushViewController(dest, animated: true)
            }
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //API delete item
            deleteFoodItem(row: indexPath.row)
        }
    }

}

extension FoodDiaryViewController: CoachMarksControllerDataSource, CoachMarksControllerDelegate {

    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        //        coachViews.bodyView.nextLabel.textColor = UIColor.white
        //        coachViews.bodyView.hintLabel.textColor = UIColor.white
        //        let dietlensRed =  UIColor(red: 242/255, green: 64/255, blue: 93/255, alpha: 1.0)
        //        coachViews.bodyView.tintColor = dietlensRed
        //        coachViews.bodyView.hintLabel.backgroundColor = dietlensRed
        //        coachViews.bodyView.nextLabel.backgroundColor = dietlensRed
        coachViews.bodyView.nextLabel.text = "Got it"
        coachViews.bodyView.hintLabel.text = "Add side dishes to complete your meal"
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }

    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        return coachMarksController.helper.makeCoachMark(for: foodTableView.tableFooterView)
    }

    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 1
    }

}
