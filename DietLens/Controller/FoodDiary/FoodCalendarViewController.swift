//
//  FoodCalendarViewController.swift
//  DietLens
//
//  Created by linby on 19/04/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
class FoodCalendarViewController: UIViewController {

    @IBOutlet weak var foodCalendarTableView: UITableView!
    @IBOutlet weak var calendarYConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeCalButton: UIButton!
     @IBOutlet weak var diaryCalendar: DiaryDatePicker!

    @IBOutlet weak var nutritionCollectionView: UICollectionView!
    @IBOutlet weak var calendarBtn: UIButton!
    @IBOutlet weak var dateLabel: UILabel!

    //dataSource
    var foodDiaryList = [FoodDiaryEntity]()
    var nutritionList = [String]()
    //passValue
    var selectedDate = Date()
    var selectedFoodDiary: FoodDiaryEntity?
    var selectedImage: UIImage?

    //calendar date attribute
    var dishWithEvent = [Date]()
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
        let dateStr = DateUtil.normalDateToString(date: selectedDate)
        getAvailableDate(year: dateStr.components(separatedBy: "-")[0], month: dateStr.components(separatedBy: "-")[1])
        getFoodDairyByDate(date: selectedDate)
    }

    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func bringInCalendar(_ sender: Any) {
        calendarYConstraint.constant = 20
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

    func getAvailableDate(year: String, month: String) {
        APIService.instance.getAvailableDate(year: year, month: month) { (dateList) in
            //mark redDot for this date
            if dateList != nil {
                self.dishWithEvent = dateList!
            }
        }
    }

    func getFoodDairyByDate(date: Date) {
        let dateStr = DateUtil.normalDateToString(date: date)
        APIService.instance.getFoodDiaryByDate(selectedDate: dateStr) { (foodDiaryList) in
            if foodDiaryList == nil {
                return
            }
            //show UItableView for all the foodDiary
            self.foodDiaryList = foodDiaryList!
            self.foodCalendarTableView.reloadData()
        }
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
        return foodDiaryList.count+1
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            APIService.instance.deleteFoodDiary(foodDiaryId: foodDiaryList[indexPath.row].foodDiaryId, completion: { (_) in
                self.foodDiaryList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            })
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == foodDiaryList.count {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "addMoreCell") {
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "FoodDiaryRecordViewCell") as? FoodDiaryRecordViewCell {
                let entity = foodDiaryList[indexPath.row]
                cell.setUpCell(imageId: entity.imageId, calorieText: entity.mealType)
                return cell
            }
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //click add more to directly add new dish into foodDiary
        if indexPath.row == foodDiaryList.count {
            if let dest = UIStoryboard(name: "AddFoodScreen", bundle: nil).instantiateViewController(withIdentifier: "AddFoodVC") as? AddFoodViewController {
                if let navigator = self.navigationController {
                    navigator.pushViewController(dest, animated: true)
                }
            }
        } else { //click food Item to edit foodItem again
            if let dest = UIStoryboard(name: "AddFoodScreen", bundle: nil).instantiateViewController(withIdentifier: "FoodDiaryVC") as? FoodDiaryViewController {
                let imageKey = foodDiaryList[indexPath.row].imageId
                //download image from Qiniu
                APIService.instance.qiniuImageDownload(imageKey: imageKey, completion: { (image) in
                    dest.foodDiaryEntity = self.foodDiaryList[indexPath.row]
                    dest.userFoodImage = image
                    if let navigator = self.navigationController {
                        navigator.pushViewController(dest, animated: true)
                    }
                })

            }
        }

    }

}
