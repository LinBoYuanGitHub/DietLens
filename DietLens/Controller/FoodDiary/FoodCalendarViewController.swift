//
//  FoodCalendarViewController.swift
//  DietLens
//
//  Created by linby on 19/04/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
import FSCalendar

class FoodCalendarViewController: UIViewController {

    @IBOutlet weak var foodCalendarTableView: UITableView!
    @IBOutlet weak var calendarYConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeCalButton: UIButton!
    @IBOutlet weak var diaryCalendar: DiaryDatePicker!

    @IBOutlet weak var nutritionCollectionView: UICollectionView!
    @IBOutlet weak var calendarBtn: UIButton!
    @IBOutlet weak var dateLabel: UILabel!

    //dataSource
    var foodMealList = [FoodDiaryMealEntity]()
    var displayDict = [Int: (String, Double)]()
    var targetDict = [Int: (String, Double)]()

    //passValue
    var selectedDate = Date()
    var selectedFoodDiary: FoodDiaryEntity?
    var selectedImage: UIImage?

    //calendar date attribute
    var datesWithEvent = [Date]()

    //setting up calendar
    fileprivate let gregorian = Calendar(identifier: .gregorian)
    fileprivate let formatter: DateFormatter = {
        let formatter = DateFormatter()
        //dateFormatter.locale = Locale(identifier: "en_GB")
        formatter.setLocalizedDateFormatFromTemplate("MMMMd")
        return formatter
    }()

    override func viewDidLoad() {
        let date = Date()
        diaryCalendar.setCurrentPage(date, animated: true)
        diaryCalendar.dataSource = self
        diaryCalendar.delegate = self
        dateLabel.text = formatter.string(from: date)
        foodCalendarTableView.delegate = self
        foodCalendarTableView.dataSource = self
        nutritionCollectionView.delegate = self
        nutritionCollectionView.dataSource = self
        dateLabel.text = formatter.string(from: selectedDate)
        foodCalendarTableView.estimatedRowHeight = 90
        foodCalendarTableView.rowHeight = UITableViewAutomaticDimension
        diaryCalendar.appearance.headerTitleColor = UIColor.black
        registerNib()
        assembleMealList(foodDiaryList: [FoodDiaryEntity]())
        loadDailyNutritionView()
    }

    @IBAction func toPersonalPage(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "nutritionInfoVC") as? DailyNutritionInfoViewController {
            controller.selectedDate = selectedDate
            present(controller, animated: true, completion: nil)
        }
    }

    func loadDailyNutritionView() {
        APIService.instance.getDailySum(date: selectedDate) { (resultDict) in
            if resultDict.count == 0 {
                return
            }
            self.assembleDisplayDict(nutritionDict: resultDict)
            self.assembleTargetDict()
            self.nutritionCollectionView.reloadData()
        }
    }

    func assembleDisplayDict(nutritionDict: Dictionary<String, Double>) {
        //TODO handle hardcode display
        displayDict[0] = ("CALORIE", nutritionDict["energy"]!)
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

    @IBAction func showCalendar(_ sender: Any) {
        bringInCalendar(sender)
    }

    @IBAction func onBackPressed(_ sender: Any) {
        if self.navigationController!.viewControllers.count > 1 {
            self.navigationController?.popViewController(animated: false)
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }

    }

    func registerNib() {
//        let nib = UINib(nibName: "diaryHeader", bundle: nil)
//        foodCalendarTableView.register(nib, forHeaderFooterViewReuseIdentifier: "DiarySectionHeader")
        let nib = UINib(nibName: "foodCalendarViewHeader", bundle: nil)
        foodCalendarTableView.register(nib, forHeaderFooterViewReuseIdentifier: "calendarSectionHeader")
        let collectionNib = UINib(nibName: "NutritionCollectionCell", bundle: nil)
        nutritionCollectionView.register(collectionNib, forCellWithReuseIdentifier: "nutritionCollectionCell")
    }

    func calculateTotalNutrition() {
        var accumulatedCalorie = 0.0
        var accumulatedCarbohydrate = 0.0
        var accumulatedProtein = 0.0
        var accumulatedFat = 0.0
        for foodMeal in foodMealList {
            for foodDiary in foodMeal.foodEntityList {
                for item in foodDiary.dietItems {
                    accumulatedCalorie += item.nutritionInfo.calorie
                    accumulatedCarbohydrate += item.nutritionInfo.carbohydrate
                    accumulatedProtein += item.nutritionInfo.protein
                    accumulatedFat += item.nutritionInfo.fat
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        getFoodDairyByDate(date: selectedDate)
        let dateStr = DateUtil.normalDateToString(date: selectedDate)
        getAvailableDate(year: dateStr.components(separatedBy: "-")[0], month: dateStr.components(separatedBy: "-")[1])
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.foodCalendarTableView.reloadData()
    }

    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func bringInCalendar(_ sender: Any) {
        calendarYConstraint.constant = 80
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)

        UIView.animate(withDuration: 0.3) {
            self.closeCalButton.alpha = 0.7
            self.diaryCalendar.alpha = 1
        }
    }

    @IBAction func dismissCalendar(_ sender: Any) {
        calendarYConstraint.constant = -360
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
            self.closeCalButton.alpha = 0
            self.diaryCalendar.alpha = 0
        }
    }

    //get available date and display in calendar
    func getAvailableDate(year: String, month: String) {
        APIService.instance.getAvailableDate(year: year, month: month) { (dateList) in
            //mark redDot for this date
            if dateList != nil {
                self.datesWithEvent = dateList!
                self.diaryCalendar.reloadData()
            }
        }
    }

    //get foodDiary form date
    func getFoodDairyByDate(date: Date) {
        let dateStr = DateUtil.normalDateToString(date: date)
        APIService.instance.getFoodDiaryByDate(selectedDate: dateStr) { (foodDiaryList) in
            if foodDiaryList == nil {
                let emptyList = [FoodDiaryEntity]()
                self.assembleMealList(foodDiaryList: emptyList)
                return
            }
            //show UItableView for all the foodDiary
            self.assembleMealList(foodDiaryList: foodDiaryList!)
        }
    }

    //assemble the meal from the server
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
        foodCalendarTableView.reloadData()
    }

}

extension FoodCalendarViewController: UICollectionViewDelegate, UICollectionViewDataSource {

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

extension FoodCalendarViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.foodMealList[section].foodEntityList.count + 1)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return foodMealList.count
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            APIService.instance.deleteFoodDiary(foodDiaryId: foodMealList[indexPath.section].foodEntityList[indexPath.row].foodDiaryId, completion: { (_) in
                self.foodMealList[indexPath.section].foodEntityList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.reloadData()
                self.loadDailyNutritionView()//recalculate nutrition info
            })
        }
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        //disable addMore delete
        if indexPath.row == self.foodMealList[indexPath.section].foodEntityList.count {
            return .none
        } else {
            return .delete
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == self.foodMealList[indexPath.section].foodEntityList.count {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "addMoreCell") {
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "FoodDiaryRecordViewCell") as? FoodDiaryRecordViewCell {
                let entity = self.foodMealList[indexPath.section].foodEntityList[indexPath.row]
                let calorieText = String(calculateCalorie(foodEntity: entity)) + StringConstants.UIString.calorieUnit
                cell.setUpCell(imageId: entity.imageId, calorieText: calorieText)
                return cell
            }
        }
        return UITableViewCell()
    }

    //calculate nutrition header for this view
    func calculateCalorie(foodEntity: FoodDiaryEntity) -> Int {
        var accumulatedCalorie = 0
        for dietItem in foodEntity.dietItems {
            accumulatedCalorie += Int(dietItem.nutritionInfo.calorie)
        }
        return accumulatedCalorie
    }

    func calculateCalorie(foodEntityList: [FoodDiaryEntity]) -> Int {
        var accumulatedCalorie = 0
        for foodEntity in foodEntityList {
            for dietItem in foodEntity.dietItems {
                accumulatedCalorie += Int(dietItem.nutritionInfo.calorie)
            }
        }
        return accumulatedCalorie
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 31 //header
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56 //row
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 4 //for section vertical spacing
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //click add more to directly add new dish into foodDiary
        if indexPath.row == self.foodMealList[indexPath.section].foodEntityList.count {
            if let dest = UIStoryboard(name: "AddFoodScreen", bundle: nil).instantiateViewController(withIdentifier: "addFoodVC") as? AddFoodViewController {
                dest.addFoodDate = selectedDate
                dest.mealType = foodMealList[indexPath.section].meal
                dest.isSetMealByTimeRequired = false
                if let navigator = self.navigationController {
                    navigator.pushViewController(dest, animated: true)
                }
            }
        } else { //click food Item to edit foodItem again
            if let dest = UIStoryboard(name: "AddFoodScreen", bundle: nil).instantiateViewController(withIdentifier: "FoodDiaryVC") as? FoodDiaryViewController {
                let imageKey = self.foodMealList[indexPath.section].foodEntityList[indexPath.row].imageId
                //download image from Qiniu
                APIService.instance.qiniuImageDownload(imageKey: imageKey, width: Dimen.foodCalendarImageWidth, height: Dimen.foodCalendarImageHeight, completion: { (image) in
                    dest.isSetMealByTimeRequired = false
                    dest.foodDiaryEntity = self.foodMealList[indexPath.section].foodEntityList[indexPath.row]
                    dest.isUpdate = true
                    if image != nil {
                        dest.userFoodImage = image
                    } else {
                        dest.userFoodImage = #imageLiteral(resourceName: "dietlens_sample_background")
                    }
                    if let navigator = self.navigationController {
                        navigator.pushViewController(dest, animated: true)
                    }

                })

            }
        }

    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "calendarSectionHeader") as? FoodCalendarSectionHeader else {
            return UITableViewHeaderFooterView()
        }
        let meal = foodMealList[section].meal
        switch meal {
        case StringConstants.MealString.breakfast:
            header.mealLabel.text = StringConstants.MealString.breakfast
            header.calorieLable.text = String(calculateCalorie(foodEntityList: foodMealList[section].foodEntityList))+StringConstants.UIString.calorieUnit
        case StringConstants.MealString.lunch:
            header.mealLabel.text = StringConstants.MealString.lunch
            header.calorieLable.text = String(calculateCalorie(foodEntityList: foodMealList[section].foodEntityList))+StringConstants.UIString.calorieUnit
        case StringConstants.MealString.dinner:
            header.mealLabel.text = StringConstants.MealString.dinner
            header.calorieLable.text = String(calculateCalorie(foodEntityList: foodMealList[section].foodEntityList))+StringConstants.UIString.calorieUnit
        case StringConstants.MealString.snack:
            header.mealLabel.text = StringConstants.MealString.snack
            header.calorieLable.text = String(calculateCalorie(foodEntityList: foodMealList[section].foodEntityList))+StringConstants.UIString.calorieUnit
        default:
            break
        }
        return header
    }

}

extension FoodCalendarViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {

    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        for dateWithEvent in datesWithEvent {
            if Calendar.current.isDate(date, inSameDayAs: dateWithEvent) {
                return 1
            }
        }
        return 0
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {

        //print("calendar did select date \(self.formatter.string(from: date))")
        let later = DispatchTime.now() + 0.3
        DispatchQueue.main.asyncAfter(deadline: later) {
            self.dismissCalendar(date)
            self.selectedDate = date
            self.dateLabel.text = self.formatter.string(from: date)
            self.getFoodDairyByDate(date: date)
            self.loadDailyNutritionView()
        }
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }
        //display today`s foodDiary from local realm
    }

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        return #colorLiteral(red: 0.9961311221, green: 0.3479750156, blue: 0.3537038565, alpha: 1)
    }

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        if Calendar.current.isDate(Date(), inSameDayAs: date) {
            return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        return nil
    }

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        return #colorLiteral(red: 0.2319577109, green: 0.2320933503, blue: 0.2404021281, alpha: 1)
    }

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderDefaultColorFor date: Date) -> UIColor? {
        if Calendar.current.isDate(Date(), inSameDayAs: date) {
            return #colorLiteral(red: 0.9961311221, green: 0.3479750156, blue: 0.3537038565, alpha: 1)
        }
        return nil
    }

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        return [#colorLiteral(red: 0.9961311221, green: 0.3479750156, blue: 0.3537038565, alpha: 1)]
    }

    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let currentDate = calendar.currentPage
        let dateStr = DateUtil.normalDateToString(date: currentDate)
        getAvailableDate(year: dateStr.components(separatedBy: "-")[0], month: dateStr.components(separatedBy: "-")[1])
//        getFoodDairyByDate(date: currentDate)
    }
}
