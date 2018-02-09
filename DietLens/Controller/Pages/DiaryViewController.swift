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
    var selectedFoodInfo = FoodInfo()
    var selectedImage: UIImage?

    var datesWithEvent = [Date]()
    var addFoodDate: Date = Date()

    var isAddNewDiary = false

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
                cell.callBackBlock { (mealType) in
                    let storyboard = UIStoryboard(name: "AddFoodScreen", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "addFoodVC") as! AddFoodViewController
                    vc.addFoodDate = self.addFoodDate
                    vc.mealType = mealType
                    self.present(vc, animated: true, completion: nil)
                    self.isAddNewDiary = true //set the addnewdiary flag
                }
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //to foodDiary detail page
        if indexLookup[indexPath.item] == -1 {
            //to add food&date
            return
        }
        selectedFoodInfo =  self.mealsConsumed[self.mealIndexLookup[indexPath.item]].foodConsumed[self.indexLookup[indexPath.item]]
        selectedFoodInfo.calories =  Double(round(10*selectedFoodInfo.calories)/10)
        selectedImage = (tableView.cellForRow(at: indexPath) as? FoodDiaryCell)?.foodImage.image
        performSegue(withIdentifier: "toDetailDiaryPage", sender: self)
        isAddNewDiary = true
    }

     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? FoodDiaryHistoryViewController {
            dest.selectedFoodInfo = selectedFoodInfo
            dest.diaryImage = selectedImage
        }
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
//        for i in 0..<4 {
//            datesWithEvent.append(gregorian.date(byAdding: .day, value: ((i+1)*3)%8, to: Date())!)
//        }
        diaryCalendar.appearance.headerTitleColor = #colorLiteral(red: 0.2319577109, green: 0.2320933503, blue: 0.2404021281, alpha: 1)
    }

    override func viewDidAppear(_ animated: Bool) {
        loadDiaryData(date: addFoodDate)
        loadDaysRecordedFromDiary(date: addFoodDate)
        diaryCalendar.reloadData()
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
        self.dismiss(animated: true, completion: nil)
//       self.revealViewController()?.revealLeftView()
        //PBRevealViewController.revealLeftView()
    }
    @IBAction func bringInCalendar(_ sender: Any) {
        calendarYConstraint.constant = 20
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)

        UIView.animate(withDuration: 0.3) {
            self.closeCalButton.alpha = 0.7
            self.diaryCalendar.alpha = 1
            if self.foodDiaryList.count == 0 {
                self.emptyDiaryIcon.alpha = 0.3
                self.emptyDiaryHelperText.alpha = 0.3
            } else {
                self.emptyDiaryIcon.alpha = 0
                self.emptyDiaryHelperText.alpha = 0
            }

        }
    }
    @IBAction func dismissCalendar(_ sender: Any) {
        calendarYConstraint.constant = -360

        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
            self.closeCalButton.alpha = 0
            self.diaryCalendar.alpha = 0
            if self.foodDiaryList.count == 0 {
                self.emptyDiaryIcon.alpha = 1
                self.emptyDiaryHelperText.alpha = 1
            } else {
                self.emptyDiaryIcon.alpha = 0
                self.emptyDiaryHelperText.alpha = 0
            }
        }
    }

    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let currentDate = calendar.currentPage
        loadDaysRecordedFromDiary(date: currentDate)
        diaryCalendar.reloadData()
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {

        //print("calendar did select date \(self.formatter.string(from: date))")
        let later = DispatchTime.now() + 0.3
        DispatchQueue.main.asyncAfter(deadline: later) {
            self.dismissCalendar(date)
            self.addFoodDate = date
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
            foodInfo.id = foodDiary.id
            foodInfo.calories = Double(round(10*foodDiary.calorie)/10)
            foodInfo.carbohydrate = foodDiary.carbohydrate
            foodInfo.protein = foodDiary.protein
            foodInfo.fat = foodDiary.fat
            foodInfo.foodName = foodDiary.foodName
            foodInfo.imageURL = foodDiary.imagePath
            foodInfo.mealType = foodDiary.mealType
            foodInfo.recordType = foodDiary.recordType
            foodInfo.portionSize = foodDiary.portionSize
            foodInfo.ingredientList = foodDiary.ingredientList
//            foodInfo.foodImage = #imageLiteral(resourceName: "laksa")
            foodInfo.servingSize = "unknown"
            if foodDiary.mealType == "Breakfast" {
                 breakfastEntity.foodConsumed.append(foodInfo)
            } else if foodDiary.mealType == "Lunch" {
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
        if isAddNewDiary {
            let range = NSRange(location: 0, length: 1)
            let sections = NSIndexSet(indexesIn: range)
            foodDiaryTable.reloadSections(sections as IndexSet, with: UITableViewRowAnimation.automatic)
            isAddNewDiary = false
        } else {
            UIView.transition(with: foodDiaryTable,
                              duration: 0.35,
                              options: .transitionCurlUp,
                              animations: { self.foodDiaryTable.reloadData() })
        }
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
