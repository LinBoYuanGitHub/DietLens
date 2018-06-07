//
//  FoodDiaryViewController.swift
//  DietLens
//
//  Created by linby on 10/04/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

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
    var foodDiaryEntity = FoodDiaryEntity()
    //passing parameter
    var userFoodImage: UIImage?
    var imageKey: String?
    var isUpdate: Bool = false //from foodCalendar then update
    //mealType data
    var mealStringArray = [StringConstants.MealString.breakfast, StringConstants.MealString.lunch, StringConstants.MealString.dinner, StringConstants.MealString.snack]
    var currentMealIndex = 0
    var isSetMealByTimeRequired: Bool = false
    @IBOutlet weak var animationViewLeading: NSLayoutConstraint!

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
    }

    func setCorrectMealType() {
        if isSetMealByTimeRequired {
            let hour: Int = Calendar.current.component(.hour, from: Date())
            if hour < ConfigVariable.BreakFastEndTime && hour > ConfigVariable.BreakFastStartTime {
                self.foodDiaryEntity.mealType = StringConstants.MealString.breakfast
                currentMealIndex = 0
                mealCollectionView.reloadData()
            } else if hour < ConfigVariable.LunchEndTime && hour > ConfigVariable.LunchStartTime {
                self.foodDiaryEntity.mealType = StringConstants.MealString.lunch
                currentMealIndex = 1
                mealCollectionView.reloadData()
            } else if hour < ConfigVariable.DinnerEndTime && hour > ConfigVariable.DinnerStartTime {
                self.foodDiaryEntity.mealType = StringConstants.MealString.dinner
                currentMealIndex = 2
                mealCollectionView.reloadData()
            } else {
                self.foodDiaryEntity.mealType = StringConstants.MealString.snack
                currentMealIndex = 3
                mealCollectionView.reloadData()
            }
        } else {
            switch self.foodDiaryEntity.mealType {
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
        if isUpdate {
            self.navigationItem.rightBarButtonItem?.title = StringConstants.UIString.updateBtnText
        } else {
            self.navigationItem.rightBarButtonItem?.title = StringConstants.UIString.saveBtnText
        }
        let textColor = UIColor(red: CGFloat(67/255), green: CGFloat(67/255), blue: CGFloat(67/255), alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: textColor, kCTFontAttributeName: UIFont(name: "PingFangSC-Regular", size: 18)!] as! [NSAttributedStringKey: Any]
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.sideMenuController?.isLeftViewSwipeGestureEnabled = false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @objc func onAddMoreClick() {
        if let dest = UIStoryboard(name: "AddFoodScreen", bundle: nil).instantiateViewController(withIdentifier: "textInputVC") as? TextInputViewController {
            dest.addFoodDate = Date()
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
    }

    //save(from text Search) or update foodDiary
    @IBAction func onTopRightBtnPressed(_ sender: Any) {
        NotificationCenter.default.post(name: .shouldRefreshMainPageNutrition, object: nil)
        if isUpdate {
            APIService.instance.updateFoodDiary(isPartialUpdate: false, foodDiary: foodDiaryEntity, completion: { (isSuccess) in
                if isSuccess {
                    if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FoodCalendarVC") as? FoodCalendarViewController {
                        for viewController in (self.navigationController?.viewControllers)! {
                            if let foodCalendarVC = viewController as? FoodCalendarViewController {
                                foodCalendarVC.shouldRefreshDiary = true
                            }
                        }
                        self.navigationController?.popViewController(animated: true) //pop back to food calendar
                    }

                } else {
                    AlertMessageHelper.showMessage(targetController: self, title: "", message: "update failed")
                }
            })
        } else {
            AlertMessageHelper.showLoadingDialog(targetController: self)
            APIService.instance.createFooDiary(foodDiary: foodDiaryEntity, completion: { (isSuccess) in
                AlertMessageHelper.dismissLoadingDialog(targetController: self) {
                    if isSuccess {
                        if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FoodCalendarVC") as? FoodCalendarViewController {
                            dest.selectedDate = DateUtil.normalStringToDate(dateStr: self.foodDiaryEntity.mealTime)
                            if let navigator = self.navigationController {
                                //pop all the view except HomePage
                                if navigator.viewControllers.contains(where: {
                                    return $0 is FoodCalendarViewController
                                }) {
                                    //add foodItem into foodDiaryVC
                                    for viewController in (self.navigationController?.viewControllers)! {
                                        if let foodCalendarVC = viewController as? FoodCalendarViewController {
                                            DispatchQueue.main.async {
                                                navigator.popToViewController(foodCalendarVC, animated: true)
                                                foodCalendarVC.shouldRefreshDiary = true
                                            }
                                        }
                                    }
                                } else {
                                    DispatchQueue.main.async {
                                        navigator.popToRootViewController(animated: false)
                                        navigator.pushViewController(dest, animated: true)
                                        dest.shouldRefreshDiary = true
                                    }
                                }
                            }
                        }
                    }
                }
            })
        }
    }

    func initFoodInfo() {
        if imageKey != nil {//set imageKey to foodDiaryEntity
            foodDiaryEntity.imageId = self.imageKey!
        }
        calculateAccumulateFoodValue()
    }

    func calculateAccumulateFoodValue() {
        var accumulatedCalorie = 0
        var accumulatedCarbohydrate = 0.0
        var accumulatedProtein = 0.0
        var accumulatedFat = 0.0
        //get accumualted value
        for dietItem in foodDiaryEntity.dietItems {
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

    //add foodDiary into item & upload
    func addFoodIntoItem(dietItem: DietItem) {
        foodDiaryEntity.dietItems.append(dietItem)
        self.calculateAccumulateFoodValue()
        self.foodTableView.reloadData()
    }

    //update foodDiary
    func updateFoodInfoItem(dietItem: DietItem) {
        for (index, entity) in foodDiaryEntity.dietItems.enumerated() {
            if entity.id == dietItem.id {
                foodDiaryEntity.dietItems[index] = dietItem
            }
        }
        self.calculateAccumulateFoodValue()
        self.foodTableView.reloadData()
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
        foodDiaryEntity.mealType = mealStringArray[indexPath.row]
        //switch collection selection
        let destX = collectionView.cellForItem(at: indexPath)?.center.x
        UIView.animate(withDuration: 0.2, delay: 0.1, usingSpringWithDamping: 0.0, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.self.animationViewLeading.constant = destX! + CGFloat(10)
        })
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CGFloat(70), height: CGFloat(35))
    }

}

extension FoodDiaryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodDiaryEntity.dietItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //name, portion calorie , deleteBtn
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FoodItemListCell") as? FoodItemListCell {
            let entity = foodDiaryEntity.dietItems[indexPath.row]
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
        AlertMessageHelper.showLoadingDialog(targetController: self)
        let foodId = foodDiaryEntity.dietItems[indexPath.row].foodId
        APIService.instance.getFoodDetail(foodId: foodId) { (dietItem) in
            AlertMessageHelper.dismissLoadingDialog(targetController: self) {
                if dietItem == nil {
                    return
                }
                //TODO replace nutrition & portion value with new request value
                let displayUnit =  self.foodDiaryEntity.dietItems[indexPath.row].displayUnit
                let quantity = self.foodDiaryEntity.dietItems[indexPath.row].quantity
                let id = self.foodDiaryEntity.dietItems[indexPath.row].id
                self.foodDiaryEntity.dietItems[indexPath.row] = dietItem!
                self.foodDiaryEntity.dietItems[indexPath.row].id = id
                self.foodDiaryEntity.dietItems[indexPath.row].displayUnit = displayUnit
                self.foodDiaryEntity.dietItems[indexPath.row].quantity = quantity
                for (index, portion) in dietItem!.portionInfo.enumerated() {
                    if portion.sizeUnit == displayUnit {
                        self.foodDiaryEntity.dietItems[indexPath.row].selectedPos = index
                    }
                }
                DispatchQueue.main.async {
                    self.jumpToFoodInfoPage(dietEntity: self.foodDiaryEntity.dietItems[indexPath.row])
                }
            }
        }
    }

    func jumpToFoodInfoPage(dietEntity: DietItem) {
        //jump to foodInfo page to modify foodInfo Item
        if let dest = UIStoryboard(name: "AddFoodScreen", bundle: nil).instantiateViewController(withIdentifier: "FoodInfoVC") as? FoodInfoViewController {
            dest.selectedPortionPos = dietEntity.selectedPos
            dest.dietItem = dietEntity
            dest.shouldShowMealBar = false
            dest.isUpdate = true
            if let navigator = self.navigationController {
                //pop all the view except HomePage
                navigator.pushViewController(dest, animated: true)
            }
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //API delete item
            AlertMessageHelper.showLoadingDialog(targetController: self)
            APIService.instance.deleteFoodItem(foodDiaryId: foodDiaryEntity.foodDiaryId, foodItemId: foodDiaryEntity.dietItems[indexPath.row].id, completion: { (_) in
                NotificationCenter.default.post(name: .shouldRefreshMainPageNutrition, object: nil)
                AlertMessageHelper.dismissLoadingDialog(targetController: self) {
                    self.foodDiaryEntity.dietItems.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    self.calculateAccumulateFoodValue()
                }
            })
        }
    }

}

extension FoodDiaryViewController {
    //toTextSearchPage -> addmore, save to foodDiary, detail page to edit
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        
//    }
}
