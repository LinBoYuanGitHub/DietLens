//
//  DiaryViewController.swift
//  DietLens
//
//  Created by next on 26/10/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit
import FSCalendar

class DiaryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FSCalendarDelegate, FSCalendarDataSource {

    @IBOutlet weak var foodDiaryTable: UITableView!
    @IBOutlet weak var calendarYConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeCalButton: UIButton!
    @IBOutlet weak var diaryCalendar: DiaryDatePicker!
    @IBOutlet weak var dateLabel: UILabel!
    var mealsConsumed = [DiaryDailyFood]()
    var indexLookup = [Int]()
    var mealIndexLookup = [Int]()
    var headerIndex: Int = 0
    var currentMealIndex: Int = -1
    var currentFoodItemIndex: Int = 0
    var totalRows: Int = 0
    fileprivate let formatter: DateFormatter = {
        let formatter = DateFormatter()
        //dateFormatter.locale = Locale(identifier: "en_GB")
        formatter.setLocalizedDateFormatFromTemplate("MMMMd")
        return formatter
    }()
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("indexPath row:\(indexPath.row), item:\(indexPath.item)")
        if indexLookup[indexPath.item] == -1 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "header") as? FoodDiaryHeaderCell {
                cell.setupHeaderCell(whichMeal: mealsConsumed[mealIndexLookup[indexPath.item]].mealOfDay)
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "foodItem") as? FoodDiaryCell {
                cell.setupCell(foodInfo: mealsConsumed[mealIndexLookup[indexPath.item]].foodConsumed[indexLookup[indexPath.item]])
                return cell
            }
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let date = Date()
        diaryCalendar.setCurrentPage(date, animated: true)
        dateLabel.text = formatter.string(from: date)
        foodDiaryTable.dataSource = self
        foodDiaryTable.delegate = self
        foodDiaryTable.estimatedRowHeight = 90
        foodDiaryTable.rowHeight = UITableViewAutomaticDimension
//        testData()
//        testOnSaveData()
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        // Do any additional setup after loading the view.
    }

    func calculateTableViewParams() {
        let numOfMeals = mealsConsumed.count
        var foodAte: Int = 0

        for meal in mealsConsumed {
            foodAte += meal.foodConsumed.count
        }

        let total = numOfMeals + foodAte
        for i in 0..<total {
            if i == headerIndex {
                indexLookup.append(-1)
                currentMealIndex += 1
                headerIndex += mealsConsumed[currentMealIndex].foodConsumed.count + 1
                currentFoodItemIndex = 0
            } else {
                indexLookup.append(currentFoodItemIndex)
                currentFoodItemIndex += 1
            }
            mealIndexLookup.append(currentMealIndex)
        }
        currentMealIndex = -1
        currentFoodItemIndex = 0
        headerIndex = 0
        totalRows = total
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {

        //print("calendar did select date \(self.formatter.string(from: date))")
        let later = DispatchTime.now() + 0.3
        let diaryFormatter = DateFormatter()
        diaryFormatter.setLocalizedDateFormatFromTemplate("dd MMM yyyy")
        DispatchQueue.main.asyncAfter(deadline: later) {
            self.dismissCalendar(date)
            self.dateLabel.text = self.formatter.string(from: date)
        }
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }
        //display today`s foodDiary from local realm
        let foodDiaryList = FoodDiaryDBOperation.instance.getFoodDiaryByDate(date: diaryFormatter.string(from: date))
//        let foodDiaryList = FoodDiaryDBOperation.instance.getAllFoodDiary()
        for foodDiary in foodDiaryList! {
            var entity: DiaryDailyFood = DiaryDailyFood()
            var foodInfo: FoodInfo = FoodInfo()
            foodInfo.calories = foodDiary.calorie
            foodInfo.foodName = foodDiary.foodName
            foodInfo.foodImage = #imageLiteral(resourceName: "laksa")
            foodInfo.servingSize = "unknown"
            entity.foodConsumed.append(foodInfo)
            entity.mealOfDay = .breakfast
            mealsConsumed.append(entity)
        }
        calculateTableViewParams()
        foodDiaryTable.reloadData()
    }

    func testOnSaveData() {
        let foodDiary = FoodDiary()
        foodDiary.mealTime = "14 Nov 2017"
        foodDiary.calorie = 210.5
        foodDiary.foodName = "testFood"
        foodDiary.foodId = "9999"
        foodDiary.carbohydrate = "0.0"
        foodDiary.protein = "0.0"
        foodDiary.fat = "0.0"
        FoodDiaryDBOperation.instance.saveFoodDiary(foodDiary: foodDiary)
    }

    func testData() {
        var f1: FoodInfo = FoodInfo()
        f1.calories = 213.1
        f1.foodImage = #imageLiteral(resourceName: "laksa")
        f1.foodName = "Singapore Laksa"
        f1.servingSize = "1 medium bowl"

        var f2: FoodInfo = FoodInfo()
        f2.calories = 210.1
        f2.foodImage = #imageLiteral(resourceName: "bg")
        f2.foodName = "Another food that is not food"
        f2.servingSize = "1 circle"

        var m1: DiaryDailyFood = DiaryDailyFood()
        m1.mealOfDay = .breakfast
        mealsConsumed.append(m1)

        m1.mealOfDay = .lunch
        m1.foodConsumed.append(f1)
        m1.foodConsumed.append(f2)
        mealsConsumed.append(m1)

        m1.mealOfDay = .dinner
        mealsConsumed.append(m1)
    }

}
