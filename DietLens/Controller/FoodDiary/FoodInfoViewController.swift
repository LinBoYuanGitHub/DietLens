//
//  FoodInfoViewController.swift
//  DietLens
//
//  Created by linby on 10/04/2018.
//  Copyright © 2018 NExT++. All rights reserved.

import UIKit
class FoodInfoViewController: UIViewController {

    @IBOutlet weak var foodSampleImage: UIImageView!
    @IBOutlet weak var foodName: UILabel!
    @IBOutlet weak var quantityValue: UITextField!
    @IBOutlet weak var unitValue: UITextField!
    @IBOutlet weak var mealCollectionView: UICollectionView!
    //configurable hide view
    @IBOutlet weak var mealTypeView: UIView!
    @IBOutlet weak var portionDataView: UIView!
    @IBOutlet weak var nutritionDataView: UIView!
    //nutrition label
    @IBOutlet weak var calorieValueLabel: UILabel!
    @IBOutlet weak var proteinValueLable: UILabel!
    @IBOutlet weak var fatValueLabel: UILabel!
    @IBOutlet weak var carbohydrateValueLabel: UILabel!
    //pickerView
    var quantityPickerView = UIPickerView()
    //data source

    var foodInfoModel = FoodInfomationModel()
    var quantity = 1.0
    var selectedPortionPos: Int = 0
    var quantityIntegerArray = [0]
    var decimalArray = [0, 0.25, 0.5, 0.75]
    var unitArray = ["Standard sizing", "Small sizing", "Large sizing", "Grams"]
    var mealStringArray = [StringConstants.MealString.breakfast, StringConstants.MealString.lunch, StringConstants.MealString.dinner, StringConstants.MealString.snack]
    var currentMealIndex = 0
    //parameter for passing value
    var userFoodImage: UIImage? //previous viewController need to pass the display image
    var foodDiaryEntity = FoodDiaryEntity()
    var dietItem = DietItem()
    var isSetMealByTimeRequired: Bool = false
    var recordType = RecordType.RecordByImage
//    var isAddIntoFoodList = false
//    var isAccumulatedDiary: Bool = false
//    var imageKey: String?

    override func viewDidLoad() {
        //init foodInfo data -> setUp View
        prepareQuantityIntegerArray()
        initFoodInfo()
        setUpViews()
        quantityValue.delegate = self
        unitValue.delegate = self
        //pickerView
        quantityPickerView.delegate = self
        quantityPickerView.dataSource = self
        //mealCollectionView
        mealCollectionView.delegate = self
        mealCollectionView.dataSource = self
        //registration for resuable nib cellItem
        mealCollectionView.register(MealTypeCollectionCell.self, forCellWithReuseIdentifier: "mealTypeCell")
        mealCollectionView.register(UINib(nibName: "MealTypeCollectionCell", bundle: nil), forCellWithReuseIdentifier: "mealTypeCell")
    }

/********************************************************
    Data setting Up part
********************************************************/
    func initFoodInfo() {
        foodDiaryEntity.dietItems.append(dietItem)
        foodName.text = dietItem.foodName
    }

    func initFoodEntity() {
        var dietItem = DietItem()
        dietItem.foodName = foodInfoModel.foodName
        dietItem.foodId = foodInfoModel.foodId
        dietItem.nutritionInfo.calorie = Double(foodInfoModel.calorie)
        dietItem.nutritionInfo.protein = Double(foodInfoModel.protein)!
        dietItem.nutritionInfo.fat = Double(foodInfoModel.fat)!
        dietItem.nutritionInfo.carbohydrate = Double(foodInfoModel.carbohydrate)!
        dietItem.quantity = Double(quantityValue.text!)!
        dietItem.selectedPos =  0
        for portion in foodInfoModel.portionList {
            var portionInfo = PortionInfo()
            portionInfo.rank = portion.rank
            portionInfo.sizeUnit = portion.sizeUnit
            portionInfo.sizeValue = portion.sizeValue
            portionInfo.weightUnit = portion.weightUnit
            portionInfo.weightValue = portion.weightValue
            dietItem.portionInfo.append(portionInfo)
        }
        dietItem.recordType = RecognitionInteger.recognition
        foodDiaryEntity.dietItems.append(dietItem)
        foodDiaryEntity.mealType = mealStringArray[0]
        foodDiaryEntity.mealTime = DateUtil.normalDateToString(date: Date())
    }

    func setUpFoodValue() {
        foodName.text = foodInfoModel.foodName
        let portionRate = Float(Double(quantity) * foodInfoModel.portionList[selectedPortionPos].weightValue/100)
        calorieValueLabel.text = String(foodInfoModel.calorie*portionRate)+" "+StringConstants.UIString.calorieUnit
        carbohydrateValueLabel.text = String(portionRate * Float(foodInfoModel.carbohydrate)!)+" "+StringConstants.UIString.diaryIngredientUnit
        proteinValueLable.text = String(portionRate * Float(foodInfoModel.protein)!) + " "+StringConstants.UIString.diaryIngredientUnit
        fatValueLabel.text = String(portionRate * Float(foodInfoModel.fat)!) + " "+StringConstants.UIString.diaryIngredientUnit
    }

/********************************************************
    View setting Up part
********************************************************/
    func setUpViews() {
        setUpImage()
        quantityValue.inputAccessoryView = setUpPickerToolBar()
        quantityValue.inputView = quantityPickerView
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapFunction))
        unitValue.addGestureRecognizer(tap)
    }

    func setUpImage() {
        if recordType == RecordType.RecordByImage {
            foodSampleImage.image = userFoodImage
        } else if recordType == RecordType.RecordByBarcode {
            foodSampleImage.image = #imageLiteral(resourceName: "barcode_sample_icon")
        } else {
            //TODO sampling image according to text category
            foodSampleImage.image = #imageLiteral(resourceName: "food_sample_image")
        }
    }

    @objc func tapFunction(_ sender: UITapGestureRecognizer) {
        showUnitSelectionDialog()
    }

    //used only when isNotAccumulate
    @objc func showUnitSelectionDialog() {
        let alert = UIAlertController(title: "", message: "Please select preferred unit", preferredStyle: UIAlertControllerStyle.alert)
        for portion in foodInfoModel.portionList {
            alert.addAction(UIAlertAction(title: portion.sizeUnit, style: UIAlertActionStyle.default, handler: { (_) in
                self.selectedPortionPos = portion.rank - 1
                self.unitValue.text = portion.sizeUnit
                self.setUpFoodValue()
            }))
        }
        self.present(alert, animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }

    //if not passing mealType, then use currentTime to set mealType
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
        if dietItem.recordType == RecordType.RecordByAdditionText {
            //1.from FoodCalendarViewController 2.first TextSearchItem
            if let dest = UIStoryboard(name: "AddFoodScreen", bundle: nil).instantiateViewController(withIdentifier: "FoodDiaryVC") as? FoodDiaryViewController {
                if let navigator = self.navigationController {
                    //pop otherView
                    if navigator.viewControllers.contains(where: {
                        return $0 is FoodDiaryViewController
                    }) {
                        //pop searchView & foodInfoView
                        navigator.popViewController(animated: true)
                        navigator.popViewController(animated: true)
                        //add foodItem into

                    } else {
                        navigator.pushViewController(dest, animated: true)
                    }

                }
            }
        } else {
            //redirect to foodDiary page
            APIService.instance.createFooDiary(foodDiary: foodDiaryEntity, completion: { (isSuccess) in
                if isSuccess {
                    //request for saving FoodDiary
                    if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FoodCalendarVC") as? FoodCalendarViewController {
                        dest.selectedDate = Date()
                        if let navigator = self.navigationController {
                            //pop all the view except HomePage
                            navigator.pushViewController(dest, animated: true)
                        }
                    }
                }
            })

        }
    }

    @IBAction func onBackPressed(_ sender: Any) {
//        dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //segue toAddTextFoodPage
        if let dest = segue.destination as? FoodDiaryViewController {
//           dest.foodItemList.append(addedFood)
            dest.userFoodImage = userFoodImage
        }
    }

    //toolBar click event region
    @objc func donePicker() {
        quantityValue.resignFirstResponder()
        //set quantityValue according to keyboard||pickerView
        if quantityValue.inputView != nil {
            let quantityPos =  quantityPickerView.selectedRow(inComponent: 0)
            let decimalPos = quantityPickerView.selectedRow(inComponent: 1)
            quantityValue.text = String(quantityIntegerArray[quantityPos]) + String(decimalArray[decimalPos])
        }
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
        foodDiaryEntity.mealType = mealStringArray[indexPath.row]
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
