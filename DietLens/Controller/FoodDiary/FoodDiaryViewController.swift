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

    override func viewDidLoad() {
        mealCollectionView.delegate = self
        mealCollectionView.dataSource = self
        foodTableView.delegate = self
        foodTableView.dataSource = self
        foodSampleImage.image = userFoodImage
        //registration for resuable nib cellItem
        mealCollectionView.register(MealTypeCollectionCell.self, forCellWithReuseIdentifier: "mealTypeCell")
        mealCollectionView.register(UINib(nibName: "MealTypeCollectionCell", bundle: nil), forCellWithReuseIdentifier: "mealTypeCell")
        initFoodInfo()
        setCorrectMealType()
        let addMoreGesture = UITapGestureRecognizer(target: self, action: #selector(onAddMoreClick))
        addMore.addGestureRecognizer(addMoreGesture)
        loadImage()
    }

    func loadImage() {
        self.foodSampleImage.image = #imageLiteral(resourceName: "loading_img")
        if isUpdate {
            APIService.instance.qiniuImageDownload(imageKey: imageKey!) { (foodImage) in
                if foodImage == nil {
                    return
                }
                self.foodSampleImage.image = foodImage
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        //move indicator to correct position
        UIView.animate(withDuration: 0.1, delay: 0.1, usingSpringWithDamping: 0.0, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.animationView.center.x = CGFloat(Float(self.currentMealIndex+1)*Float(80)) + CGFloat(10)
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
        self.navigationController?.navigationBar.isHidden = false
        if isUpdate {
            self.navigationItem.rightBarButtonItem?.title = StringConstants.UIString.updateBtnText
        } else {
            self.navigationItem.rightBarButtonItem?.title = StringConstants.UIString.saveBtnText
        }
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
        if isUpdate {
            APIService.instance.updateFoodDiary(isPartialUpdate: true, foodDiary: foodDiaryEntity, completion: { (isSuccess) in
                if isSuccess {
                   self.navigationController?.popViewController(animated: true)//pop back to food calendar
                } else {
                    AlertMessageHelper.showMessage(targetController: self, title: "", message: "update failed")
                }
            })
        } else {
            APIService.instance.createFooDiary(foodDiary: foodDiaryEntity, completion: { (isSuccess) in
                if isSuccess {
                    if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FoodCalendarVC") as? FoodCalendarViewController {
                        dest.selectedDate = DateUtil.normalStringToDate(dateStr: self.foodDiaryEntity.mealTime)
                        if let navigator = self.navigationController {
                            //pop all the view except HomePage
                            if navigator.viewControllers.contains(where: {
                                return $0 is FoodCalendarViewController
                            }) {
                                //add foodItem into foodDiaryVC
                                for vc in (self.navigationController?.viewControllers)! {
                                    if let foodCalendarVC = vc as? FoodCalendarViewController {
                                        navigator.popToViewController(foodCalendarVC, animated: true)
                                    }
                                }
                            } else {
                                navigator.popToRootViewController(animated: false)
                                navigator.pushViewController(dest, animated: true)
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
        var accumulatedCarbohydrate = 0
        var accumulatedProtein = 0
        var accumulatedFat = 0
        //get accumualted value
        for dietItem in foodDiaryEntity.dietItems {
            accumulatedCalorie += Int(dietItem.nutritionInfo.calorie*dietItem.quantity)
            accumulatedCarbohydrate += Int(dietItem.nutritionInfo.carbohydrate*dietItem.quantity)
            accumulatedProtein += Int(dietItem.nutritionInfo.protein*dietItem.quantity)
            accumulatedFat += Int(dietItem.nutritionInfo.fat*dietItem.quantity)
        }
        calorieValueLabel.text = String(accumulatedCalorie) + StringConstants.UIString.calorieUnit
        carbohydrateLabel.text = String(accumulatedCarbohydrate) + StringConstants.UIString.diaryIngredientUnit
        proteinValueLable.text = String(accumulatedProtein) + StringConstants.UIString.diaryIngredientUnit
        fatValueLabel.text = String(accumulatedFat) + StringConstants.UIString.diaryIngredientUnit
    }

    //add foodDiary into item & upload
    func addFoodIntoItem(dietItem: DietItem) {
        foodDiaryEntity.dietItems.append(dietItem)
        if isUpdate {
            APIService.instance.updateFoodDiary(isPartialUpdate: false, foodDiary: foodDiaryEntity) { (isSuccess) in
                if isSuccess {
                    self.foodTableView.reloadData()
                    self.calculateAccumulateFoodValue()
                }
            }
        } else {//create new item need to wait
             self.foodTableView.reloadData()
        }
    }

    //update foodDiary
    func updateFoodInfoItem(dietItem: DietItem) {
        for (index, entity) in foodDiaryEntity.dietItems.enumerated() {
            if entity.id == dietItem.id {
                foodDiaryEntity.dietItems[index] = dietItem
            }
        }
        APIService.instance.updateFoodDiary(isPartialUpdate: false, foodDiary: foodDiaryEntity) { (isSuccess) in
            if isSuccess {
                self.foodTableView.reloadData()
                self.calculateAccumulateFoodValue()
            } else {
                AlertMessageHelper.showMessage(targetController: self, title: "", message: "update failed")
            }
        }
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
            self.animationView.center.x = destX! + 50
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
            AlertMessageHelper.dismissLoadingDialog(targetController: self)
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
            APIService.instance.deleteFoodItem(foodDiaryId: foodDiaryEntity.foodDiaryId, foodItemId: foodDiaryEntity.dietItems[indexPath.row].id, completion: { (_) in
                    self.foodDiaryEntity.dietItems.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    self.calculateAccumulateFoodValue()
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
