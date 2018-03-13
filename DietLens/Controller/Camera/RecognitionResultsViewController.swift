//
//  RecognitionResultsViewController.swift
//  DietLens
//
//  Created by next on 14/11/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class RecognitionResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    //food select dialog part
    @IBOutlet weak var selectDishView: UIView!
//    @IBOutlet weak var foodSelectionView: UIView!
//    @IBOutlet weak var optionListTable: UITableView!
    @IBOutlet weak var foodNameOptionTable: UITableView!

    //Header-Food Image part
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var foodCalorie: UILabel!
    @IBOutlet weak var caloriePercentage: UILabel!

    //Header-User Input Item part
    @IBOutlet weak var foodName: UITextField!
    @IBOutlet weak var quantityStack: UIStackView!
    @IBOutlet weak var unitStack: UIStackView!

    @IBOutlet weak var TFquantity: UITextField!
    @IBOutlet weak var TFunit: UITextField!

//    @IBOutlet weak var portionStack: UIStackView!
//    @IBOutlet weak var TFfoodPercentage: UITextField!
    @IBOutlet weak var TFmealType: UITextField!
    @IBOutlet weak var recognizeDataTable: UITableView!
    @IBOutlet weak var footer: UIView!

    //reference of adapter for the ingredient
    var ingredientAdapter: PlainTextTableAdapter<UITableViewCell>!

    //picker & ArrayOfData for Picker
    var mealitemPicker: UIPickerView!
    var unitPicker: UIPickerView!
    var unitPickerData: [String] = ["portion"]
//    var percentageitemPicker: UIPickerView!
//    var percentagePickerData = ["25%", "50%", "75%", "100%", "150%", "200%", "300%", "400%"]
    var mealPickerData = ["Breakfast", "Lunch", "Dinner", "Snack"]

    var dateTime: Date? //previous controller should always pass dateTime

    var userFoodImage: UIImage?
    var whichMeal: Meal = .breakfast
    var isSetMealByTimeRequired = true
    var results: [FoodInfomation]?
    var foodDiary = FoodDiary()
    var recordType: String?

    // use the flag to mark whether app should dismiss when user close selection dialog
    var shouldDismissFromSelection: Bool = true
    var imageId = 0

//    var ingredientDeleteHandler: ((Int) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        //delegate
        foodNameOptionTable.dataSource = self
        foodNameOptionTable.delegate = self
        foodName.delegate = self
//        TFfoodPercentage.delegate = self
        TFquantity.keyboardType = UIKeyboardType.decimalPad
        TFquantity.delegate = self
        TFunit.delegate = self
        TFmealType.delegate = self
        //set up image
        foodImage.contentMode = .scaleAspectFill
        if userFoodImage != nil {
            foodImage.image = userFoodImage
        } else {
            foodImage.image = #imageLiteral(resourceName: "laksa")
        }
        //set up tableview adapter
        setUpIngredientTableAdapter()
        //set picker view
        setUpPickerView()
        setUpUnitList(pos: 0)
        setUpInputView()
        //set taleview
        setFoodDataList()
        recognizeDataTable.dataSource = ingredientAdapter
        recognizeDataTable.delegate = ingredientAdapter
        recognizeDataTable.tableHeaderView = header
        recognizeDataTable.tableHeaderView?.fs_height = 550
        recognizeDataTable.tableFooterView = footer
        setMealType()
        //regist header here
        registTableHeader()
    }

    func registTableHeader() {
        let nib = UINib(nibName: "IngredientHeader", bundle: nil)
        recognizeDataTable.register(nib, forHeaderFooterViewReuseIdentifier: "IngredientSectionHeader")
        NotificationCenter.default.addObserver(self, selector: #selector(onPlusBtnPressed(_:)), name: .onIngredientPlusBtnClick, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onAddIngredient(_:)), name: .addIngredient, object: nil)
    }

    func setUpIngredientTableAdapter() {
        ingredientAdapter = PlainTextTableAdapter()
        ingredientAdapter.callBack = { (index) in
            //remove work
            self.ingredientAdapter.ingredientTextList.remove(at: index)
            let removedIngredient =  self.foodDiary.ingredientList[index]
            self.foodDiary.ingredientList.remove(at: index)
            //recalculate
            self.foodDiary.calorie -= removedIngredient.calorie
            self.foodDiary.calorie = abs(self.foodDiary.calorie)
            self.foodDiary.carbohydrate = String(Double(self.foodDiary.carbohydrate)!-removedIngredient.carbs)
            self.foodDiary.protein = String(Double(self.foodDiary.protein)!-removedIngredient.protein)
            self.foodDiary.fat = String(Double(self.foodDiary.fat)!-removedIngredient.fat)
            self.setFoodDataList()
            self.recognizeDataTable.reloadData()
        }
    }

    @objc func onAddIngredient(_ notification: NSNotification) {
        if let diaryIngredient = notification.userInfo?["ingredientdiary"] as? IngredientDiary {
            //TODO fix realm add code problem
            let realm = try! Realm()
            do {
                try realm.write({
                    foodDiary.ingredientList.append(diaryIngredient)
                    //acccumulate nutrtion
                    foodDiary.calorie += diaryIngredient.calorie
                    foodDiary.carbohydrate = String(Double(foodDiary.carbohydrate)!+diaryIngredient.carbs)
                    foodDiary.protein = String(Double(foodDiary.protein)!+diaryIngredient.protein)
                    foodDiary.fat = String(Double(foodDiary.fat)!+diaryIngredient.fat)
                })
            } catch let error {
                print(error)
            }
            //reload table to show added ingredient
            ingredientAdapter.ingredientTextList.append(diaryIngredient.ingredientName + "  " + String(diaryIngredient.quantity*diaryIngredient.weight) + StringConstants.UIString.diaryIngredientUnit)
            //reload the data
            setFoodDataList()
            recognizeDataTable.reloadData()
        }
    }

    func setMealType() {
        if isSetMealByTimeRequired {
            let hour: Int = Calendar.current.component(.hour, from: Date())
            if hour < ConfigVariable.BreakFastEndTime && hour > ConfigVariable.BreakFastStartTime {
                self.whichMeal = .breakfast
                TFmealType.text = StringConstants.MealString.breakfast
                mealitemPicker.selectRow(0, inComponent: 0, animated: false)
            } else if hour < ConfigVariable.LunchEndTime && hour > ConfigVariable.LunchStartTime {
                self.whichMeal = .lunch
                TFmealType.text =  StringConstants.MealString.lunch
                mealitemPicker.selectRow(1, inComponent: 0, animated: false)
            } else if hour < ConfigVariable.DinnerEndTime && hour > ConfigVariable.DinnerStartTime {
                self.whichMeal = .dinner
                TFmealType.text = StringConstants.MealString.dinner
                mealitemPicker.selectRow(2, inComponent: 0, animated: false)
            } else {
                self.whichMeal = .snack
                TFmealType.text = StringConstants.MealString.snack
                mealitemPicker.selectRow(3, inComponent: 0, animated: false)
            }
        } else {
            switch whichMeal {
            case Meal.breakfast:
                TFmealType.text = StringConstants.MealString.breakfast
                mealitemPicker.selectRow(0, inComponent: 0, animated: false)
            case Meal.lunch:
                TFmealType.text = StringConstants.MealString.lunch
                mealitemPicker.selectRow(1, inComponent: 0, animated: false)
            case Meal.dinner:
                TFmealType.text = StringConstants.MealString.dinner
                mealitemPicker.selectRow(2, inComponent: 0, animated: false)
            case Meal.snack:
                TFmealType.text = StringConstants.MealString.snack
                mealitemPicker.selectRow(3, inComponent: 0, animated: false)
            }
        }

    }

    func setFoodDataList() {
        let unitPosition = unitPicker.selectedRow(inComponent: 0)
        let ratio: Double = Double(TFquantity.text!)!*results![foodDiary.rank-1].portionList[unitPosition].weightValue
        ingredientAdapter.nutritionTextList.removeAll()
        let total_calories = round(10*Double(foodDiary.calorie)*ratio)/1000
        let total_carbohydrate = round(10*Double(foodDiary.carbohydrate)!*ratio)/1000
        let total_protein = round(10*Double(foodDiary.protein)!*ratio)/1000
        let total_fat = round(10*Double(foodDiary.fat)!*ratio)/1000
        ingredientAdapter.nutritionTextList.append(NutrtionData.calorieText + "   \(String(total_calories))"+StringConstants.UIString.calorieUnit)
        ingredientAdapter.nutritionTextList.append(NutrtionData.carbohydrateText + "   \(String(total_carbohydrate))"+StringConstants.UIString.diaryIngredientUnit)
        ingredientAdapter.nutritionTextList.append(NutrtionData.proteinText + "   \(String(total_protein))"+StringConstants.UIString.diaryIngredientUnit)
        ingredientAdapter.nutritionTextList.append(NutrtionData.fatText + "   \(String(total_fat))"+StringConstants.UIString.diaryIngredientUnit)
        //adjust calorie textlabel
        ingredientAdapter.totalWeight = 0.0
        for ingredient in foodDiary.ingredientList {
            ingredientAdapter.totalWeight += ingredient.weight
        }
//        TFfoodPercentage.text = "\(round(foodDiary.portionSize))%"
        foodCalorie.text = "\(round(total_calories)) "+StringConstants.UIString.calorieUnit
        caloriePercentage.text = "\(round(total_calories/20))% of your daily calorie intake"
    }

    func setUpUnitList(pos: Int) {
        unitPickerData.removeAll()
        for portion in results![pos].portionList {
            unitPickerData.append(portion.sizeUnit)
        }
        unitPicker.selectRow(0, inComponent: 0, animated: false)
        TFunit.text = unitPickerData[0]
        //recalculate nutrition data
        setFoodDataList()
    }

    func setUpPickerView() {
        mealitemPicker = UIPickerView()
        unitPicker = UIPickerView()
        mealitemPicker.dataSource = self
        mealitemPicker.delegate = self
        mealitemPicker.showsSelectionIndicator = true
        mealitemPicker.accessibilityViewIsModal = true
        unitPicker.dataSource = self
        unitPicker.delegate = self
        unitPicker.showsSelectionIndicator = true
        unitPicker.accessibilityViewIsModal = true
        //set up picker tool bar
        let pickerToolBar = setUpPickerToolBar()
//        TFmealType.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchDown)
        TFmealType.inputView = mealitemPicker
        TFmealType.inputAccessoryView = pickerToolBar
//        TFunit.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchDown)
        TFunit.inputView = unitPicker
        TFunit.inputAccessoryView = pickerToolBar
//        TFfoodPercentage.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchDown)
//        TFfoodPercentage.inputView = percentageitemPicker
//        TFfoodPercentage.inputAccessoryView = pickerToolBar
//        TFfoodPercentage.text = percentagePickerData[3]
    }

    func setUpPickerToolBar() -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)

        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        return toolBar
    }

    @objc func donePicker() {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            self.foodDiary.unit = self.unitPickerData[self.unitPicker.selectedRow(inComponent: 0)]
//            self.foodDiary.portionSize = Double(self.percentagePickerData[self.percentageitemPicker.selectedRow(inComponent: 0)].replacingOccurrences(of: "%", with: ""))!
            self.setFoodDataList()
            self.recognizeDataTable.reloadData()
        }
        TFmealType.resignFirstResponder()
        TFquantity.resignFirstResponder()
        TFunit.resignFirstResponder()
//        TFfoodPercentage.resignFirstResponder()
    }

    func setUpInputView() {
        if recordType == "recognition"{
            selectDishView.alpha = 1
            foodName.text = results![0].foodName
            setFoodInfoIntoDiary(foodInfo: results![0])
            setFoodDataList()
//            if results == nil || results?.count == 0 {
//                results = [FoodInfomation]()
//                var f1 = FoodInfomation()
//                f1.foodName = "laksa"
//                results!.append(f1)
//                f1.foodName = "mee goreng"
//                results!.append(f1)
//                f1.foodName = "laksa goreng"
//                results!.append(f1)
//                f1.foodName = "nasi goreng"
//                results!.append(f1)
//                f1.foodName = "beehoon goreng"
//                results!.append(f1)
//                f1.foodName = "kway tiao goreng"
//                results!.append(f1)
//            } else {

//            }
        } else if (recordType == "barcode"||recordType == "text") {
            selectDishView.alpha = 0
            //hide ingredientinput
            foodName.text = results![0].foodName
            setFoodInfoIntoDiary(foodInfo: results![0])
            setFoodDataList()
        } else if recordType == "customized" {
            selectDishView.alpha = 0
            ingredientAdapter.isShowIngredient = true
            ingredientAdapter.isShowPlusBtn = true
            for ingredient in foodDiary.ingredientList {
                ingredientAdapter.ingredientTextList.append(ingredient.ingredientName + "  " +  String(ingredient.quantity*ingredient.weight) + "g")
            }
            recognizeDataTable.reloadData()
        }
        //register tap gesture recognition
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        header.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
        keyboardWillHide()
    }

    func keyboardWillHide() {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y += (100)
        }
    }

    // The number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == unitPicker {
            return unitPickerData.count
        } else if pickerView == mealitemPicker {
            return mealPickerData.count
        }
        return 0
    }

    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == unitPicker {
            return unitPickerData[row]
        } else if pickerView == mealitemPicker {
            foodDiary.mealType = mealPickerData[row]
            return mealPickerData[row]
        }
        return ""
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
         if pickerView == unitPicker {
            TFunit.text = unitPickerData[row]
        } else if pickerView == mealitemPicker {
            TFmealType.text = mealPickerData[row]
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if results != nil {
            return results!.count
        }
        return 6
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodNameCell") as? FoodNameCell //UITableViewCell()
        cell?.setUpCell(sampleImagePath: results![indexPath.row].sampleImagePath, name: "\(results![indexPath.row].foodName)", calorie: "\(results![indexPath.row].calorie) kcal")
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseInOut, animations: {
            self.selectDishView.alpha = 0
        }, completion: nil)
//        foodName.isUserInteractionEnabled = false
        foodName.text = results![indexPath.row].foodName
        foodCalorie.text = String(results![indexPath.row].calorie) + " kcal"
        caloriePercentage.text = "\(Int(results![indexPath.row].calorie/20))% of your daily calorie intake"
        setFoodInfoIntoDiary(foodInfo: results![indexPath.row])
        setUpUnitList(pos: indexPath.row)
        //set click action on foodName,mealType,eaten percentage
        recordType = "recognition"
        foodDiary.rank = indexPath.row + 1//set selection rank
        shouldDismissFromSelection = false
        //show portion
        //hide ingredient
        foodName.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchDown)
        //reload nutrtion data
        setFoodDataList()
        recognizeDataTable.reloadData()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }

    @objc func buttonClicked(_ sender: AnyObject?) {
        if recordType == "recognition" {
            if sender === foodName {
                UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseInOut, animations: {
                    self.selectDishView.alpha = 1
                }, completion: nil)
            }
        }

    }

    func setFoodInfoIntoDiary(foodInfo: FoodInfomation) {
        foodDiary.foodId = foodInfo.foodId
        foodDiary.foodName = foodInfo.foodName
        foodDiary.calorie = Double(foodInfo.calorie)
        foodDiary.carbohydrate = foodInfo.carbohydrate
        foodDiary.protein = foodInfo.protein
        foodDiary.fat = foodInfo.fat
        //        foodDiary?.recordType
        //        foodDiary?.imagePath
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onCloseBtnPressed(_ sender: Any) {
        //back to camera page
        if shouldDismissFromSelection {
            dismiss(animated: true, completion: nil)
        } else {
            UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseInOut, animations: {
                self.selectDishView.alpha = 0
            }, completion: nil)
        }
    }

    @IBAction func doneButtonPressed(_ sender: Any) {
//        if recordType == "customized" && ingredientAdapter.ingredientTextList.count == 0 {
//            AlertMessageHelper.showMessage(targetController: self, title: "Note", message: "you haven't add any ingredients yet!")
//            return
//        }
        self.foodDiary.foodName = self.foodName.text!
        self.foodDiary.mealTime = DateUtil.formatGMTDateToString(date: self.dateTime!)
        self.foodDiary.recordType = self.recordType!
        self.foodDiary.mealType = self.TFmealType.text!
        self.foodDiary.quantity = Double(self.TFquantity.text!)!
        self.foodDiary.unit = self.TFunit.text!
        //upload to server
        let preferences = UserDefaults.standard
        let key = "userId"
        let userId = preferences.string(forKey: key)
        let nutrientJson: JSON = assembleNutrtionString()
        let ingredientString = assembleIngredientString()
        //TODO show loading progress bar for saving image
        APIService.instance.saveFoodDiary(userId: userId!, foodDiary: foodDiary, mealTime: foodDiary.mealTime, mealType: foodDiary.mealType, nutrientJson: nutrientJson.rawString()!, ingredientJson: ingredientString, recordType: foodDiary.recordType, category: foodDiary.category, rank: foodDiary.rank, quantity: foodDiary.quantity, unit: foodDiary.unit, imageId: imageId) { (flag) in
            if flag {
                self.saveImage(imgData: UIImageJPEGRepresentation(self.foodImage.image!, 1)!, filename: String(Date().timeIntervalSince1970 * 1000)+".png")
                DispatchQueue.main.async {
                    FoodDiaryDBOperation.instance.saveFoodDiary(foodDiary: self.foodDiary)
                    self.dismiss(animated: false) {
                        NotificationCenter.default.post(name: .addDiaryDismiss, object: nil)
                    }
                }
            } else {
                AlertMessageHelper.showMessage(targetController: self, title: "", message: "food Diary save failed")
            }
        }
        print("Ate \(foodName.text ?? "none") for \(whichMeal) on \(dateTime)")
    }

    func assembleNutrtionString() -> JSON {
        let nutrientJson: JSON = [
            NutrtionData.calorieText: foodDiary.calorie,
            NutrtionData.carbohydrateText: foodDiary.carbohydrate,
            NutrtionData.proteinText: foodDiary.protein,
            NutrtionData.fatText: foodDiary.fat
        ]
        return nutrientJson
    }

    func assembleIngredientString() -> String {
        var ingredientString = ""
        if foodDiary.ingredientList.count == 0 {
            ingredientString = "[]"
        } else {
            ingredientString = "["
            for ingredient in  foodDiary.ingredientList {
                let json: JSON = [
                    "id": ingredient.id,
                    "ingredientId": ingredient.ingredientId,
                    "ingredientName": ingredient.ingredientName,
                    "calorie": ingredient.calorie,
                    "carbs": ingredient.carbs,
                    "protein": ingredient.protein,
                    "fat": ingredient.fat,
                    "quantity": ingredient.quantity,
                    "unit": ingredient.unit,
                    "weight": ingredient.weight
                ]
                ingredientString += json.rawString()! + ","
            }
            ingredientString = ingredientString.substring(to: ingredientString.index(before: ingredientString.endIndex))
            ingredientString += "]"
        }
        return ingredientString
    }

    func saveImage(imgData: Data, filename: String) {
        var documentsUrl: URL {
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
        let writePath = documentsUrl.appendingPathComponent(filename)
        try? imgData.write(to: writePath, options: .atomic)
        foodDiary.imagePath = filename
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func optionNotInList(_ sender: Any) {
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseInOut, animations: {
            self.selectDishView.alpha = 0
            self.foodName.text = ""
        }, completion: nil)
        recordType = "customized"
        //reset food nutrition data
        foodDiary.calorie = 0.0
        foodDiary.carbohydrate = "0.0"
        foodDiary.protein = "0.0"
        foodDiary.fat = "0.0"
        setFoodDataList()
        //hide portion
        //show ingredient
        //change the reminder
        foodCalorie.text = ""
        caloriePercentage.text = ""
        ingredientAdapter.isShowIngredient = true
        recognizeDataTable.tableHeaderView?.fs_height = 480
        UIView.animate(withDuration: 0.3) {
            self.recognizeDataTable.tableHeaderView?.fs_height = (self.recognizeDataTable.tableHeaderView?.fs_height)! - CGFloat(100)
//            self.portionStack.isHidden = true
            self.quantityStack.isHidden = true
            self.unitStack.isHidden = true
            self.recognizeDataTable.reloadData()
        }
    }

    @IBAction func changeButtonPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseInOut, animations: {
            self.selectDishView.alpha = 1
        }, completion: nil)
    }

    @objc func onPlusBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "toAddIngredient", sender: self)
    }
    /**
     * Called when 'return' key pressed. return NO to ignore.
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    /**
     * Called when the user click on the view (outside the UITextField).
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//         if textField == TFfoodPercentage || textField == TFmealType
        if textField == TFmealType || textField == TFunit || textField == TFquantity {
            return true
        } else if recordType == "customized" && textField == foodName {
            foodName.removeTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchDown)
            return true
        } else {
            return false
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == TFquantity {
            setFoodDataList()
            recognizeDataTable.reloadData()
        }
    }

}
