//
//  DiaryViewController.swift
//  DietLens
//
//  Created by next on 26/10/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit
import FSCalendar
import PBRevealViewController

class DiaryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {

    @IBOutlet weak var foodDiaryTable: UITableView!
    @IBOutlet weak var calendarYConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeCalButton: UIButton!
    @IBOutlet weak var diaryCalendar: DiaryDatePicker!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var emptyDiaryHelperText: UILabel!
    @IBOutlet weak var emptyDiaryIcon: UIImageView!
    @IBOutlet weak var closeButton: UIButton!

    var mealsConsumed = [DiaryDailyFood]()
    var foodDiaryList = [FoodDiary]()
    var indexLookup = [Int]()
    var mealIndexLookup = [Int]()
    var headerIndex: Int = 0
    var currentMealIndex: Int = -1
    var currentFoodItemIndex: Int = 0
    var totalRows: Int = 0
     //tableview cell cache
    let imageCache = NSCache<NSString, AnyObject>()

    var datesWithEvent = [Date]()

    fileprivate let gregorian = Calendar(identifier: .gregorian)
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
                let headerSelect = UIView()
                headerSelect.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = headerSelect
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "foodItem") as? FoodDiaryCell {
                cell.foodImage.image = #imageLiteral(resourceName: "loading_img")
                var documentsUrl: URL {
                    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                }
                let fileName: String = self.mealsConsumed[self.mealIndexLookup[indexPath.item]].foodConsumed[self.indexLookup[indexPath.item]].imageURL!
                let filePath = documentsUrl.appendingPathComponent(fileName).path
                if FileManager.default.fileExists(atPath: filePath) {
                    DispatchQueue.main.async {
                        if let cachedImage = self.imageCache.object(forKey: fileName as NSString) as? UIImage {
                            cell.foodImage.image = cachedImage
                            return
                        } else {
                            cell.foodImage.image = UIImage(contentsOfFile: filePath)
                            self.imageCache.setObject(UIImage(contentsOfFile: (filePath as NSString) as String)!, forKey: fileName as NSString)
                        }
                    }
                }
                DispatchQueue.main.async {
                    cell.setupCell(foodInfo: self.mealsConsumed[self.mealIndexLookup[indexPath.item]].foodConsumed[self.indexLookup[indexPath.item]])
                }
                return cell
            }
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
    }

    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        for dateWithEvent in datesWithEvent {
            if Calendar.current.isDate(date, inSameDayAs: dateWithEvent) {
                return 1
            }
        }
        return 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let date = Date()
        diaryCalendar.setCurrentPage(date, animated: true)
        diaryCalendar.dataSource = self
        diaryCalendar.delegate = self
        dateLabel.text = formatter.string(from: date)
        foodDiaryTable.dataSource = self
        foodDiaryTable.delegate = self
        foodDiaryTable.estimatedRowHeight = 90
        foodDiaryTable.rowHeight = UITableViewAutomaticDimension
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        closeButton.target(forAction: #selector(PBRevealViewController.revealLeftView), withSender: nil)
        closeButton.actions(forTarget: PBRevealViewController.revealLeftView, forControlEvent: .touchUpInside)
        //closeButton.target = self.revealViewController()
        //closeButton.action = #selector(PBRevealViewController.revealLeftView)

//        testOnSaveData()
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        // Do any additional setup after loading the view.

        loadDiaryData(date: Date())
//        testData()
        // Adding random date as events

        loadDaysRecordedFromDiary(date: Date())
//        for i in 0..<4 {
//            datesWithEvent.append(gregorian.date(byAdding: .day, value: ((i+1)*3)%8, to: Date())!)
//        }
    }

    func loadDaysRecordedFromDiary(date: Date) {
        let diaryDateFormatter = DateFormatter()
        diaryDateFormatter.setLocalizedDateFormatFromTemplate("yyyyMMM")
        let dateString: String = diaryDateFormatter.string(from: date)
        if let allFoodInMonth = FoodDiaryDBOperation.instance.getFoodDiaryByMonth(year: String(dateString[4...]), month: String(dateString[..<3])) {
            var uniqueDates = Set<Date>()
            let dateFormatterDB = DateFormatter()
            dateFormatterDB.dateFormat = "dd MMM y"
            for var food in allFoodInMonth {
                //print(food.mealTime)
                uniqueDates.insert(dateFormatterDB.date(from: food.mealTime) ?? Date())
            }
            datesWithEvent = uniqueDates.sorted()
        }

    }

    func calculateTableViewParams() {
        indexLookup.removeAll()
        mealIndexLookup.removeAll()
        currentFoodItemIndex = 0
        headerIndex = 0
        currentMealIndex = -1
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
        //self.dismiss(animated: true, completion: nil)
       self.revealViewController()?.revealLeftView()// PBRevealViewController.revealLeftView()
    }
    @IBAction func bringInCalendar(_ sender: Any) {
        calendarYConstraint.constant = 20
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)

        UIView.animate(withDuration: 0.3) {
            self.closeCalButton.alpha = 0.7
            self.diaryCalendar.alpha = 1
            self.emptyDiaryIcon.alpha = 0.3
            self.emptyDiaryHelperText.alpha = 0.3
        }
    }
    @IBAction func dismissCalendar(_ sender: Any) {
        calendarYConstraint.constant = -360

        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
            self.closeCalButton.alpha = 0
            self.diaryCalendar.alpha = 0
            self.emptyDiaryIcon.alpha = 1
            self.emptyDiaryHelperText.alpha = 1
        }
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {

        //print("calendar did select date \(self.formatter.string(from: date))")
        let later = DispatchTime.now() + 0.3
        DispatchQueue.main.asyncAfter(deadline: later) {
            self.dismissCalendar(date)
            self.dateLabel.text = self.formatter.string(from: date)
            self.loadDiaryData(date: date)
            self.loadDaysRecordedFromDiary(date: date)
        }
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }
        //display today`s foodDiary from local realm
    }

    func loadDiaryData(date: Date) {
        let diaryFormatter = DateFormatter()
        diaryFormatter.setLocalizedDateFormatFromTemplate("dd MMM yyyy")
        foodDiaryList = FoodDiaryDBOperation.instance.getFoodDiaryByDate(date: diaryFormatter.string(from: date))!
        mealsConsumed.removeAll()
        var breakfastEntity: DiaryDailyFood = DiaryDailyFood()
        var lunchEntity: DiaryDailyFood = DiaryDailyFood()
        var dinnerEntity: DiaryDailyFood = DiaryDailyFood()
        breakfastEntity.mealOfDay = .breakfast
        lunchEntity.mealOfDay = .lunch
        dinnerEntity.mealOfDay = .dinner
        for foodDiary in foodDiaryList {
            var foodInfo: FoodInfo = FoodInfo()
            foodInfo.calories = foodDiary.calorie
            foodInfo.foodName = foodDiary.foodName
            foodInfo.imageURL = foodDiary.imagePath
//            foodInfo.foodImage = #imageLiteral(resourceName: "laksa")
            foodInfo.servingSize = "unknown"
            if foodDiary.mealType == "breakfast" {
                 breakfastEntity.foodConsumed.append(foodInfo)
            } else if foodDiary.mealType == "lunch" {
                lunchEntity.foodConsumed.append(foodInfo)
            } else {
                dinnerEntity.foodConsumed.append(foodInfo)
            }
        }
        if foodDiaryList.count == 0 {
            emptyDiaryHelperText.alpha = 1
            emptyDiaryIcon.alpha = 1
        } else {
            emptyDiaryHelperText.alpha = 0
            emptyDiaryIcon.alpha = 0
        }
        mealsConsumed.append(breakfastEntity)
        mealsConsumed.append(lunchEntity)
        mealsConsumed.append(dinnerEntity)
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
//        f1.foodImage = #imageLiteral(resourceName: "laksa")
        f1.foodName = "Singapore Laksa"
        f1.servingSize = "1 medium bowl"

        var f2: FoodInfo = FoodInfo()
        f2.calories = 210.1
//        f2.foodImage = #imageLiteral(resourceName: "bg")
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
        return #colorLiteral(red: 0.9961311221, green: 0.3479750156, blue: 0.3537038565, alpha: 1)
    }

}

extension String {
    subscript(value: PartialRangeUpTo<Int>) -> Substring {
        get {
            return self[..<index(startIndex, offsetBy: value.upperBound)]
        }
    }

    subscript(value: PartialRangeThrough<Int>) -> Substring {
        get {
            return self[...index(startIndex, offsetBy: value.upperBound)]
        }
    }

    subscript(value: PartialRangeFrom<Int>) -> Substring {
        get {
            return self[index(startIndex, offsetBy: value.lowerBound)...]
        }
    }
}
