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
    
    var nutritionList = [String]()
    //passValue
    var selectedDate = Date()
    var selectedFoodDiary: FoodDiaryEntity?
    var selectedImage: UIImage?

    //calendar date attribute
    var datesWithEvent = [Date]()
    var addFoodDate: Date = Date()

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
        dateLabel.text = formatter.string(from: date)
        foodCalendarTableView.delegate = self
        foodCalendarTableView.dataSource = self
        dateLabel.text = formatter.string(from: selectedDate)
        foodCalendarTableView.estimatedRowHeight = 90
        foodCalendarTableView.rowHeight = UITableViewAutomaticDimension
        diaryCalendar.appearance.headerTitleColor = UIColor.black
        registTableHeader()
    }

    func registTableHeader() {
        let nib = UINib(nibName: "diaryHeader", bundle: nil)
        foodCalendarTableView.register(nib, forHeaderFooterViewReuseIdentifier: "DiarySectionHeader")
    }

    override func viewDidAppear(_ animated: Bool) {
        getFoodDairyByDate(date: selectedDate)
        let dateStr = DateUtil.normalDateToString(date: selectedDate)
        getAvailableDate(year: dateStr.components(separatedBy: "-")[0], month: dateStr.components(separatedBy: "-")[1])
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
                return
            }
            //show UItableView for all the foodDiary
            self.assembleMealList(foodDiaryList: foodDiaryList!)
            self.foodCalendarTableView.reloadData()
        }
    }

    //assemble the meal from the server
    func assembleMealList(foodDiaryList: [FoodDiaryEntity]) {
        var breakfastEntity = FoodDiaryMealEntity()
        var lunchEntity = FoodDiaryMealEntity()
        var dinnerEntity = FoodDiaryMealEntity()
        var snackEntity = FoodDiaryMealEntity()
        breakfastEntity.meal = StringConstants.MealString.breakfast
        lunchEntity.meal = StringConstants.MealString.lunch
        dinnerEntity.meal = StringConstants.MealString.dinner
        snackEntity.meal = StringConstants.MealString.snack
        for foodDiary in foodDiaryList{
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
        return nutritionList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "foodCateogryCell", for: indexPath) as? NutritionCollectionCell {
            return cell
        }
        return UICollectionViewCell()
    }

}

extension FoodCalendarViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodMealList.count
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            APIService.instance.deleteFoodDiary(foodDiaryId: foodMealList[indexPath.section].foodEntityList[indexPath.row].foodDiaryId, completion: { (_) in
                self.foodMealList[indexPath.section].foodEntityList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            })
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
                cell.setUpCell(imageId: entity.imageId, calorieText: entity.mealType)
                return cell
            }
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //click add more to directly add new dish into foodDiary
        if indexPath.row == self.foodMealList[indexPath.section].foodEntityList.count {
            if let dest = UIStoryboard(name: "AddFoodScreen", bundle: nil).instantiateViewController(withIdentifier: "AddFoodVC") as? AddFoodViewController {
                if let navigator = self.navigationController {
                    navigator.pushViewController(dest, animated: true)
                }
            }
        } else { //click food Item to edit foodItem again
            if let dest = UIStoryboard(name: "AddFoodScreen", bundle: nil).instantiateViewController(withIdentifier: "FoodDiaryVC") as? FoodDiaryViewController {
                let imageKey = self.foodMealList[indexPath.section].foodEntityList[indexPath.row].imageId
                //download image from Qiniu
                APIService.instance.qiniuImageDownload(imageKey: imageKey, completion: { (image) in
                    dest.foodDiaryEntity = self.self.foodMealList[indexPath.section].foodEntityList[indexPath.row]
                    dest.userFoodImage = image
                    if let navigator = self.navigationController {
                        navigator.pushViewController(dest, animated: true)
                    }
                })

            }
        }

    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DiarySectionHeader") as? DiarySectionHeader else {
            return UITableViewHeaderFooterView()
        }
        let meal = foodMealList[section].meal
        switch meal {
        case StringConstants.MealString.breakfast:
            header.diaryLabel.text = StringConstants.MealString.breakfast
            header.addLabel.tag = 0
        case StringConstants.MealString.lunch:
            header.diaryLabel.text = StringConstants.MealString.lunch
            header.addLabel.tag = 1
        case StringConstants.MealString.dinner:
            header.diaryLabel.text = StringConstants.MealString.dinner
            header.addLabel.tag = 2
        case StringConstants.MealString.snack:
            header.diaryLabel.text = StringConstants.MealString.snack
            header.addLabel.tag = 3
        default:
            break
        }
        header.addLabel.addTarget(self, action: #selector(onAddFoodFromDiary(_:)), for: .touchUpInside)
        return header
    }
    
    //to camera to add foodDiary again
    @objc func onAddFoodFromDiary(_ sender: UIButton) {
        
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
            self.addFoodDate = date
            self.dateLabel.text = self.formatter.string(from: date)
            self.getFoodDairyByDate(date: date)
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
        getFoodDairyByDate(date: currentDate)
    }
}
