//
//  FoodDiaryHistoryViewController.swift
//  DietLens
//
//  Created by linby on 2018/6/22.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

enum FoodDiaryStatus {
    case edit
    case normal
}

class FoodDiaryHistoryViewController: BaseViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var dialogContainer: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var calendarBtn: UIButton!
    @IBOutlet weak var nutritionCollectionView: UICollectionView!
    @IBOutlet weak var foodDiaryMealTable: UITableView!
//    @IBOutlet weak var editBtn: UIBarButtonItem!
    //left right arrow
    @IBOutlet weak var leftArrowButton: ExpandedUIButton!
    @IBOutlet weak var rightArrowButton: ExpandedUIButton!
    @IBOutlet weak var editBtn: ExpandedUIButton!

    //bottom dialog view
    @IBOutlet weak var bottomDialog: UIView!
    @IBOutlet weak var distanceToBottom: NSLayoutConstraint!

    //data part
    var foodMealList = [FoodDiaryMealEntity]()
    var displayDict = [Int: (String, Double)]()
    var targetDict = [Int: (String, Double)]()
    var trashItemIds = [String]()
    //edit or norm status
    var currentEditStatus = FoodDiaryStatus.normal

    //passValue
    var selectedDate = Date()
    var shouldRefreshDiary = true

    //calendar date attribute
    var datesWithEvent = [Date]()

    fileprivate let gregorian = Calendar(identifier: .gregorian)
    fileprivate let formatter: DateFormatter = {
        let formatter = DateFormatter()
        //dateFormatter.locale = Locale(identifier: "en_GB")
        formatter.setLocalizedDateFormatFromTemplate("EEE, dd MMM")
        return formatter
    }()

    override func viewDidLoad() {
        internetDelegate = self
        foodDiaryMealTable.delegate = self
        foodDiaryMealTable.dataSource = self
        nutritionCollectionView.delegate = self
        nutritionCollectionView.dataSource = self
        dateLabel.text = formatter.string(from: selectedDate)
        rightArrowButton.setImage(UIImage(imageLiteralResourceName: "calendar_right_arrow_gray"), for: .disabled)
        //judge whether is same date
        rightArrowButton.isEnabled = !Calendar.current.isDate(selectedDate, inSameDayAs: Date())
        registerNib()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadDailyNutritionView()
        self.navigationController?.navigationBar.isHidden = true
        //load available date & load calendar data
        if shouldRefreshDiary {
            refreshFoodDiaryData()
        }
        self.foodDiaryMealTable.reloadData()
    }

    func refreshFoodDiaryData() {
        getFoodDairyByDate(date: selectedDate)
        let dateStr = DateUtil.normalDateToString(date: selectedDate)
        getAvailableDate(year: dateStr.components(separatedBy: "-")[0], month: dateStr.components(separatedBy: "-")[1])
        //set refresh falg to false
        shouldRefreshDiary = false
    }

    func registerNib() {
        let nib = UINib(nibName: "foodCalendarViewHeader", bundle: nil)
        foodDiaryMealTable.register(nib, forHeaderFooterViewReuseIdentifier: "calendarSectionHeader")
        let collectionNib = UINib(nibName: "NutritionCollectionCell", bundle: nil)
        nutritionCollectionView.register(collectionNib, forCellWithReuseIdentifier: "nutritionCollectionCell")
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

    //************************************************************************************
    // UI IBAction Area
    //************************************************************************************

    @IBAction func showCalendar(_ sender: Any) {
        if let calendarDialog = self.storyboard?.instantiateViewController(withIdentifier: "calendarDialogVC") as? CalendarDialogViewController {
            calendarDialog.calendarDelegate = self
            calendarDialog.providesPresentationContextTransitionStyle = true
            calendarDialog.preferredContentSize = CGSize(width: self.view.frame.width, height: 300)
            calendarDialog.modalPresentationStyle = UIModalPresentationStyle.popover
            //set up popover presentation controller
            calendarDialog.popoverPresentationController?.permittedArrowDirections = .up
            calendarDialog.popoverPresentationController?.backgroundColor = UIColor.white
            calendarDialog.popoverPresentationController?.sourceView = self.calendarBtn
            calendarDialog.popoverPresentationController?.sourceRect = calendarBtn.bounds
            calendarDialog.popoverPresentationController?.delegate = self
            calendarDialog.datesWithEvent = datesWithEvent
            calendarDialog.selectedDate = selectedDate
            self.present(calendarDialog, animated: true, completion: nil)
        }

    }

    @IBAction func onMoreBtnClick(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "nutritionInfoVC") as? DailyNutritionInfoViewController {
            controller.selectedDate = selectedDate
            self.navigationController?.pushViewController(controller, animated: true)
//            present(controller, animated: true, completion: nil)
        }
    }

    @IBAction func onEditButtonPressed(_ sender: Any) {
        switchToEditStatus()
    }

    @objc func switchToEditStatus() {
        currentEditStatus = FoodDiaryStatus.edit
        foodDiaryMealTable.reloadData()
        self.parent?.navigationController?.navigationBar.topItem?.title = "Edit"
        self.parent?.navigationItem.rightBarButtonItem?.isEnabled = false
        self.parent?.navigationItem.rightBarButtonItem?.title = nil
        distanceToBottom.constant = 54
        dialogContainer.isHidden = false
        editBtn.isHidden = true
    }

    @IBAction func switchToNormalStatus(_ sender: Any) {
        currentEditStatus = FoodDiaryStatus.normal
        foodDiaryMealTable.reloadData()
        self.parent?.navigationController?.navigationBar.topItem?.title = "Food Diary"
        self.parent?.navigationItem.rightBarButtonItem?.isEnabled = true
        self.parent?.navigationItem.rightBarButtonItem?.title = "Edit"
        distanceToBottom.constant = 0
        dialogContainer.isHidden = true
        editBtn.isHidden = false
        //remove all the trash items
        trashItemIds.removeAll()
    }

    @IBAction func performDeleteFood(_ sender: Any) {
        APIService.instance.deleteFoodDiaryList(foodDiaryIds: trashItemIds) { (isSuccess) in
            if isSuccess {
                self.switchToNormalStatus(self)
                self.getFoodDairyByDate(date: self.selectedDate)
                NotificationCenter.default.post(name: .shouldRefreshMainPageNutrition, object: nil)
                self.loadDailyNutritionView()
            }
        }
    }

    @IBAction func onLeftArrowPressed(_ sender: Any) {
        //adjust selectedDate
        var component = DateComponents()
        component.day = -1
        selectedDate = Calendar.current.date(byAdding: component, to: selectedDate)!
        //judge whether is same date
        rightArrowButton.isEnabled = !Calendar.current.isDate(selectedDate, inSameDayAs: Date())
        //request data & UI Change
        self.dateLabel.text = self.formatter.string(from: selectedDate)
        self.loadDailyNutritionView()
        getFoodDairyByDate(date: selectedDate)
    }

    @IBAction func onRightArrowPressed(_ sender: Any) {
        //adjust selectedDate
        var component = DateComponents()
        component.day = 1
        selectedDate = Calendar.current.date(byAdding: component, to: selectedDate)!
        //judge whether is same date
        rightArrowButton.isEnabled = !Calendar.current.isDate(selectedDate, inSameDayAs: Date())
        //request data & UI Change
        self.dateLabel.text = self.formatter.string(from: selectedDate)
        self.loadDailyNutritionView()
        getFoodDairyByDate(date: selectedDate)
    }

    //************************************************************************************
    // private data calculation method
    //************************************************************************************

    func getFoodDairyByDate(date: Date) {
        let dateStr = DateUtil.normalDateToString(date: date)
        APIService.instance.getFoodDiaryByDate(selectedDate: dateStr) { (foodDiaryList) in
//            AlertMessageHelper.dismissLoadingDialog(targetController: self)
//            self.hideLoadingDialog()
            if foodDiaryList == nil {
                let emptyList = [FoodDiaryEntity]()
                self.assembleMealList(foodDiaryList: emptyList)
                return
            }
            //show UItableView for all the foodDiary
            self.assembleMealList(foodDiaryList: foodDiaryList!)
        }
    }

    func loadDailyNutritionView() {
        APIService.instance.getDailySum(source: self, date: selectedDate) { (resultDict) in
            if resultDict.count == 0 {
                return
            }
            self.assembleDisplayDict(nutritionDict: resultDict)
            self.assembleTargetDict()
            self.nutritionCollectionView.reloadData()
        }
    }

    func assembleDisplayDict(nutritionDict: [String: Double]) {
        displayDict[0] = ("CALORIE", floor(nutritionDict["energy"]!))
        displayDict[1] = ("PROTEIN", nutritionDict["protein"]!)
        displayDict[2] = ("FAT", nutritionDict["fat"]!)
        displayDict[3] = ("CARB", nutritionDict["carbohydrate"]!)
    }

    func assembleTargetDict() {
        let preferences = UserDefaults.standard
        targetDict[0] =  (StringConstants.UIString.calorieUnit, preferences.double(forKey: PreferenceKey.calorieTarget))
        targetDict[1] =  (StringConstants.UIString.diaryIngredientUnit, preferences.double(forKey: PreferenceKey.proteinTarget))
        targetDict[2] =  (StringConstants.UIString.diaryIngredientUnit, preferences.double(forKey: PreferenceKey.fatTarget))
        targetDict[3] =  (StringConstants.UIString.diaryIngredientUnit, preferences.double(forKey: PreferenceKey.carbohydrateTarget))
    }

    func assembleMealList(foodDiaryList: [FoodDiaryEntity]) {
        foodMealList.removeAll()
        var breakfastEntity = FoodDiaryMealEntity()
        var lunchEntity = FoodDiaryMealEntity()
        var dinnerEntity = FoodDiaryMealEntity()
        var snackEntity = FoodDiaryMealEntity()
        breakfastEntity.meal = StringConstants.MealString.breakfast
        lunchEntity.meal = StringConstants.MealString.lunch
        dinnerEntity.meal = StringConstants.MealString.dinner
        snackEntity.meal = StringConstants.MealString.snack
        for foodDiary in foodDiaryList {
            switch foodDiary.mealType {
            case StringConstants.MealString.breakfast:
                breakfastEntity.foodEntityList.append(foodDiary)
            case StringConstants.MealString.lunch:
                lunchEntity.foodEntityList.append(foodDiary)
            case StringConstants.MealString.dinner:
                dinnerEntity.foodEntityList.append(foodDiary)
            case StringConstants.MealString.snack:
                snackEntity.foodEntityList.append(foodDiary)
            default:
                break
            }
        }
        foodMealList.append(breakfastEntity)
        foodMealList.append(lunchEntity)
        foodMealList.append(dinnerEntity)
        foodMealList.append(snackEntity)
        foodDiaryMealTable.reloadData()
    }

    func getAvailableDate(year: String, month: String) {
        APIService.instance.getAvailableDate(year: year, month: month) { (dateList) in
            //mark redDot for this date
            if dateList != nil {
                self.datesWithEvent = dateList!
            }
        }
    }

}

extension FoodDiaryHistoryViewController: UITableViewDelegate, UITableViewDataSource, FoodDiaryTableCellDelegate {

    func didEnterAddFoodPage(mealPos: Int) {
        if let dest = UIStoryboard(name: "AddFoodScreen", bundle: nil).instantiateViewController(withIdentifier: "addFoodVC") as? AddFoodViewController {
            dest.addFoodDate = selectedDate
            dest.mealType = foodMealList[mealPos].meal
            dest.isSetMealByTimeRequired = false
            if let navigator = self.navigationController {
                navigator.pushViewController(dest, animated: true)
            }
        }
    }

    func toggleFoodDiaryTrashItem(foodDiaryId: String, isAddedToTrash: Bool) {
        if isAddedToTrash {
            trashItemIds.append(foodDiaryId)
        } else {
            let index = trashItemIds.index(of: foodDiaryId)
            if index != nil {
                trashItemIds.remove(at: index!)
            }
        }
    }

    func didSelectFoodDiaryItem(foodDiary: FoodDiaryEntity) {
            FoodDiaryDataManager.instance.foodDiaryEntity = foodDiary
            if let dest = UIStoryboard(name: "AddFoodScreen", bundle: nil).instantiateViewController(withIdentifier: "FoodDiaryVC") as? FoodDiaryViewController {
                var imageKey = foodDiary.imageId
                //pass correct imageId
                if foodDiary.imageId == "" {
                    imageKey = foodDiary.placeHolderImage
                } else {
                    imageKey = foodDiary.imageId
                }
                dest.isSetMealByTimeRequired = false
                dest.isUpdate = true
                dest.imageKey = imageKey
                if imageKey == "" {
                    dest.userFoodImage = #imageLiteral(resourceName: "dietlens_sample_background")
                }
                if let navigator = self.navigationController {
                    navigator.pushViewController(dest, animated: true)
                }
            }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return foodMealList.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //each section only have 1 uicollectionView
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FoodDiaryTableViewCell") as? FoodDairyTableViewCell {
            cell.setUpCell(foodDiaryList: self.foodMealList[indexPath.section].foodEntityList, currentEditStatus: currentEditStatus, delegate: self)
            cell.mealSection = indexPath.section
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 31 //header
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(85 * (foodMealList[indexPath.section].foodEntityList.count/4+1))
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 4 //footer for section vertical spacing
    }

    func calculateCalorie(foodEntity: FoodDiaryEntity) -> Int {
        var accumulatedCalorie = 0
        for dietItem in foodEntity.dietItems {
            var ratio = dietItem.quantity
            if dietItem.portionInfo.count != 0 {
                ratio = dietItem.quantity*dietItem.portionInfo[dietItem.selectedPos].weightValue/100
            }
            accumulatedCalorie += Int(dietItem.nutritionInfo.calorie*ratio)
        }
        return accumulatedCalorie
    }

    func calculateCalorie(foodEntityList: [FoodDiaryEntity]) -> Int {
        var accumulatedCalorie = 0
        for foodEntity in foodEntityList {
            accumulatedCalorie += calculateCalorie(foodEntity: foodEntity)
        }
        return accumulatedCalorie
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "calendarSectionHeader") as? FoodCalendarSectionHeader else {
            return UITableViewHeaderFooterView()
        }
        header.contentView.backgroundColor = UIColor.white
        let meal = foodMealList[section].meal
        switch meal {
        case StringConstants.MealString.breakfast:
            header.mealLabel.text = StringConstants.MealString.breakfast
        case StringConstants.MealString.lunch:
            header.mealLabel.text = StringConstants.MealString.lunch
        case StringConstants.MealString.dinner:
            header.mealLabel.text = StringConstants.MealString.dinner
        case StringConstants.MealString.snack:
            header.mealLabel.text = StringConstants.MealString.snack
        default:
            break
        }
        header.calorieLable.text = String(calculateCalorie(foodEntityList: foodMealList[section].foodEntityList))+StringConstants.UIString.calorieUnit
        return header
    }

}

extension FoodDiaryHistoryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayDict.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "nutritionCollectionCell", for: indexPath) as? NutritionCollectionCell {
            let kvSet = displayDict[indexPath.row]
            let targetSet = targetDict[indexPath.row]
            var name = ""
            var progress =  0
            let unit  = targetSet!.0
            if kvSet != nil || targetSet != nil {
                if targetSet!.1 == 0 {
                    progress = 0
                } else {
                    progress = Int(kvSet!.1/targetSet!.1*100)
                }
                name = (kvSet?.0)!
            }
            cell.setUpCell(nutritionName: name, percentage: Int(progress), nutritionValue: (kvSet?.1)!, unit: unit)
            return cell
        }
        return UICollectionViewCell()
    }

}

extension FoodDiaryHistoryViewController: CalendarAlertDelegate {

    func onCalendarDateSelected(selectedDate: Date) {
        if selectedDate > Date() {
            self.dismiss(animated: true, completion: nil)
            return
        }
        let later = DispatchTime.now() + 0.3
        DispatchQueue.main.asyncAfter(deadline: later) {
            //operation dismiss the dialog
            self.selectedDate = selectedDate
            //judge whether is same date
            self.rightArrowButton.isEnabled = !Calendar.current.isDate(selectedDate, inSameDayAs: Date())
            self.dateLabel.text = self.formatter.string(from: selectedDate)
            self.getFoodDairyByDate(date: selectedDate)
            self.loadDailyNutritionView()
            self.dismiss(animated: true, completion: nil)
        }
    }

    func onCalendarCurrentPageDidChange(changedDate: Date) {
      //current page change callback
    }

}

extension FoodDiaryHistoryViewController: InternetDelegate {

    func onInternetConnected() {
        super.dismissNoInternetDialog()
        refreshFoodDiaryData()
        loadDailyNutritionView()
    }

    func onLosingInternetConnection() {
       super.showNoInternetDialog()
    }

}
