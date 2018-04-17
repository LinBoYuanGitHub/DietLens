//
//  FoodInfoViewController.swift
//  DietLens
//
//  Created by linby on 10/04/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
class FoodInfoViewController: UIViewController {

    @IBOutlet weak var foodSampleImage: UIImageView!
    @IBOutlet weak var calorieValueLabel: UILabel!
    @IBOutlet weak var proteinValueLable: UILabel!
    @IBOutlet weak var fatValueLabel: UILabel!
    @IBOutlet weak var carbohydrateValueLabel: UILabel!
    @IBOutlet weak var foodName: UILabel!
    @IBOutlet weak var quantityValue: UITextField!
    @IBOutlet weak var unitValue: UITextField!
    @IBOutlet weak var mealCollectionView: UICollectionView!

    //configurable hide view
    @IBOutlet weak var mealTypeView: UIView!
    @IBOutlet weak var portionDataView: UIView!
    @IBOutlet weak var nutritionDataView: UIView!

    //pickerView
    var quantityPickerView = UIPickerView()
    //data source
    var addedFood = FoodInfomation()
    var portionUnit = PortionModel()
    var quantity: Double = 1.0
    var quantityIntegerArray = [0]
    var decimalArray = [0, 0.25, 0.5, 0.75]
    var unitArray = ["Standard sizing", "Small sizing", "Large sizing", "Grams"]
    var mealStringArray = [StringConstants.MealString.breakfast, StringConstants.MealString.lunch, StringConstants.MealString.dinner, StringConstants.MealString.snack]
    var currentMealIndex = 0

    //parameter for passing value
    var userFoodImage: UIImage?
    var mealType: Meal = .breakfast
    var isSetMealByTimeRequired: Bool = false
    var isAddIntoFoodList = false
    //directly create foodDiary or put it into shouldCreateFoodDiary
    var isAccumulatedDiary: Bool = false

    override func viewDidLoad() {
        prepareQuantityIntegerArray()
        foodSampleImage.image = userFoodImage
        quantityValue.delegate = self
        unitValue.delegate = self
        quantityValue.inputAccessoryView = setUpPickerToolBar()
        //pickerView
        quantityPickerView.delegate = self
        quantityPickerView.dataSource = self
        quantityValue.inputView = quantityPickerView
        mealCollectionView.delegate = self
        mealCollectionView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {

    }

    //if not passing mealType, then use currentTime to set mealType
    func setCorrectMealType() {
        if isSetMealByTimeRequired {
            let hour: Int = Calendar.current.component(.hour, from: Date())
            if hour < ConfigVariable.BreakFastEndTime && hour > ConfigVariable.BreakFastStartTime {
                self.mealType = .breakfast
                currentMealIndex = 0
                mealCollectionView.reloadData()
            } else if hour < ConfigVariable.LunchEndTime && hour > ConfigVariable.LunchStartTime {
                self.mealType = .lunch
                currentMealIndex = 1
                mealCollectionView.reloadData()
            } else if hour < ConfigVariable.DinnerEndTime && hour > ConfigVariable.DinnerStartTime {
                self.mealType = .dinner
                currentMealIndex = 2
                mealCollectionView.reloadData()
            } else {
                self.mealType = .snack
                currentMealIndex = 3
                mealCollectionView.reloadData()
            }
        } else {
            switch self.mealType {
            case Meal.breakfast:
                currentMealIndex = 0
                mealCollectionView.reloadData()
            case Meal.lunch:
                currentMealIndex = 1
                mealCollectionView.reloadData()
            case Meal.dinner:
                currentMealIndex = 2
                mealCollectionView.reloadData()
            case Meal.snack:
                currentMealIndex = 3
                mealCollectionView.reloadData()
            }
        }
    }

    func prepareQuantityIntegerArray() {
        quantityIntegerArray.removeAll()
        for i in 0...20 {
            quantityIntegerArray.append(i)
        }
    }

    func setUpPickerView() {
        quantityPickerView.dataSource = self
        quantityPickerView.delegate = self
        quantityPickerView.showsSelectionIndicator = true
        quantityPickerView.accessibilityViewIsModal = true
    }

    func setUpPickerToolBar() -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 94/255, green: 94/255, blue: 94/255, alpha: 1)
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker))
        let scrollTabBtn = UIBarButtonItem(title: "scroll", style: UIBarButtonItemStyle.plain, target: self, action: #selector(switchToDatePicker))
        let keyboardBtn = UIBarButtonItem(title: "keyboard", style: UIBarButtonItemStyle.plain, target: self, action: #selector(switchToKeyboard))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([scrollTabBtn, keyboardBtn, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        return toolBar
    }

    @IBAction func onAddBtnClicked(_ sender: Any) {
        if isAccumulatedDiary {
            performSegue(withIdentifier: "toAddTextFoodPage", sender: nil)
        } else {
            //redirect to foodDiary page

        }
    }

    @IBAction func onBackPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //segue toAddTextFoodPage
        if let dest = segue.destination as? FoodDiaryViewController {
            dest.foodItemList.append(addedFood)
            dest.foodImage.image = userFoodImage
        }
    }

    //toolBar click event region
    @objc func donePicker() {
        quantityValue.resignFirstResponder()
    }

    @objc func switchToDatePicker() {
        quantityValue.inputView = quantityPickerView
        quantityValue.reloadInputViews()
    }

    @objc func switchToKeyboard() {
        quantityValue.inputView = nil
        quantityValue.keyboardType = UIKeyboardType.decimalPad
        quantityValue.reloadInputViews()
    }

    func keyboardWillShow() {
        self.mealTypeView.frame.origin.y -= (40)
        self.nutritionDataView.frame.origin.y -= (40)
        self.portionDataView.frame.origin.y -= (40)
    }

    func keyboardWillHide() {
        self.mealTypeView.frame.origin.y += (40)
        self.nutritionDataView.frame.origin.y += (40)
        self.portionDataView.frame.origin.y += (40)
    }

    func flipToShowNutrition() {

    }

}

extension FoodInfoViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return quantityIntegerArray.count
        } else {
            return decimalArray.count
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return String(quantityIntegerArray[row])
        } else {
            return String(decimalArray[row])
        }
    }
}

extension FoodInfoViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mealStringArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if currentMealIndex == indexPath.row {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mealTypeCell", for: indexPath) as? MealTypeCollectionCell {
                cell.setUpCell(isHightLight: true, mealStr: mealStringArray[indexPath.row])
                return cell
            }
        } else {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mealTypeCell", for: indexPath) as? MealTypeCollectionCell {
                cell.setUpCell(isHightLight: false, mealStr: mealStringArray[indexPath.row])
                return cell
            }
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //change the mealType block selection
        currentMealIndex = indexPath.row
        let mealStr = mealStringArray[indexPath.row]
        switch mealStr {
        case StringConstants.MealString.breakfast:
            mealType = .breakfast
        case StringConstants.MealString.lunch:
            mealType = .lunch
        case StringConstants.MealString.dinner:
            mealType = .dinner
        case StringConstants.MealString.snack:
            mealType = .snack
        default:
            break
        }
        //switch collection selection
        mealCollectionView.reloadData()
    }

}

extension FoodInfoViewController: UITextFieldDelegate {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == quantityValue {
            keyboardWillShow()
            return true
        } else if textField == unitValue {
            return false
        }
        return false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == quantityValue {
            keyboardWillHide()
           //change the nutrition data
        }
    }

}
