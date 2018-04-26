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
    //container
    @IBOutlet weak var container: UIView!
    //pickerView
    var quantityPickerView = UIPickerView()

    //data source
//    var foodInfoModel = FoodInfomationModel()
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
    var imageKey: String?

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
        //add notification for the keyboard
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil
        )
    }

/********************************************************
    Data setting Up part
********************************************************/
    func initFoodInfo() {
        foodDiaryEntity.dietItems.append(dietItem)
        setUpFoodValue()
    }

    func setUpFoodValue() {
        foodName.text = dietItem.foodName
        let portionRate = Double(dietItem.quantity) * dietItem.portionInfo[selectedPortionPos].weightValue/100
        calorieValueLabel.text = String(dietItem.nutritionInfo.calorie * portionRate)+" "+StringConstants.UIString.calorieUnit
        carbohydrateValueLabel.text = String(portionRate * dietItem.nutritionInfo.carbohydrate)+" "+StringConstants.UIString.diaryIngredientUnit
        proteinValueLable.text = String(portionRate * dietItem.nutritionInfo.protein) + " "+StringConstants.UIString.diaryIngredientUnit
        fatValueLabel.text = String(portionRate * dietItem.nutritionInfo.fat) + " "+StringConstants.UIString.diaryIngredientUnit
    }

/********************************************************
    View setting Up part
********************************************************/
    func setUpViews() {
        setUpImage()
        quantityValue.inputAccessoryView = setUpPickerToolBar()
        quantityValue.inputView = quantityPickerView
    }

    func setUpImage() {
        if recordType ==  RecognitionInteger.recognition {
            foodDiaryEntity.imageId = imageKey!
            foodSampleImage.image = userFoodImage
        } else if recordType == RecognitionInteger.barcode {
            foodSampleImage.image = #imageLiteral(resourceName: "barcode_sample_icon")
        } else {
            foodSampleImage.image = #imageLiteral(resourceName: "dietlens_sample_background")
        }
    }

    @IBAction func onQuantityBtnClicked(_ sender: Any) {
        quantityValue.becomeFirstResponder()
    }

    @IBAction func onUnitBtnClicked(_ sender: Any) {
        showUnitSelectionDialog()
    }

    //used only when isNotAccumulate
    @objc func showUnitSelectionDialog() {
        let alert = UIAlertController(title: "", message: "Please select preferred unit", preferredStyle: UIAlertControllerStyle.alert)
        for portion in dietItem.portionInfo {
            alert.addAction(UIAlertAction(title: portion.sizeUnit, style: UIAlertActionStyle.default, handler: { (_) in
                self.selectedPortionPos = portion.rank - 1
                self.unitValue.text = portion.sizeUnit
                self.setUpFoodValue()
            }))
        }
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
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
            quantityValue.text = String(Double(quantityIntegerArray[quantityPos])+Double(decimalArray[decimalPos]))
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

    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.container.frame.origin.y = view.frame.height - keyboardHeight-self.container.frame.size.height + CGFloat(50)
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
            self.container.frame.origin.y = foodSampleImage.frame.origin.y + foodSampleImage.frame.size.height + CGFloat(4)
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

extension FoodInfoViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

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

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CGFloat(70), height: CGFloat(35))
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
            return true
        } else if textField == unitValue {
            return false
        }
        return false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == quantityValue {
            dietItem.quantity = Double(quantityValue.text!)!
           //change the nutrition data
            setUpFoodValue()
        }
    }

}
