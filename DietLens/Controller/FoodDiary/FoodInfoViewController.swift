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
    @IBOutlet weak var animationView: UIView!
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

    @IBOutlet weak var mealIconView: UIImageView!
    @IBOutlet weak var mealViewHeight: NSLayoutConstraint!
    //data source
//    var foodInfoModel = FoodInfomationModel()
    var quantity = 1.0
    var selectedPortionPos: Int = 0
    var quantityIntegerArray = [0]
    var decimalArray = [0, 0.25, 0.5, 0.75]
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
    var isUpdate: Bool = false
    var shouldShowMealBar = true
    var currentIntegerPos = 1
    var currentDecimalPos = 0
    @IBOutlet weak var containerTopConstraints: NSLayoutConstraint!

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
        setUpQuantityPickerIndex()
    }

    func setUpQuantityPickerIndex() {
        if isUpdate {
            currentIntegerPos = Int(floor(dietItem.quantity))
            for (index, element) in decimalArray.enumerated() {
                if element == (dietItem.quantity - floor(dietItem.quantity)) {
                    currentDecimalPos = index
                }
            }
        }
    }

/********************************************************
    Data setting Up part
********************************************************/
    func initFoodInfo() {
        foodDiaryEntity.dietItems.append(dietItem)
        setUpFoodValue()
        setCorrectMealType()
        setUpMealBar()
    }

    func setUpMealBar() {
        if shouldShowMealBar {
            mealViewHeight.constant = 28
            mealIconView.isHidden = false
            animationView.isHidden = false
        } else {
            mealViewHeight.constant = 0.01
            mealIconView.isHidden = true
            animationView.isHidden = true
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func setUpFoodValue() {
        foodName.text = dietItem.foodName
        var portionRate: Double = Double(dietItem.quantity) * 1.0
        if dietItem.portionInfo.count != 0 {
            portionRate = Double(dietItem.quantity) * dietItem.portionInfo[selectedPortionPos].weightValue/100
        }
        calorieValueLabel.text = String(Int(dietItem.nutritionInfo.calorie * portionRate))+" "+StringConstants.UIString.calorieUnit
        carbohydrateValueLabel.text = String(format: "%.1f", dietItem.nutritionInfo.carbohydrate * portionRate)+" "+StringConstants.UIString.diaryIngredientUnit
        proteinValueLable.text = String(format: "%.1f", dietItem.nutritionInfo.protein * portionRate) + " "+StringConstants.UIString.diaryIngredientUnit
        fatValueLabel.text = String(format: "%.1f", dietItem.nutritionInfo.fat * portionRate) + " "+StringConstants.UIString.diaryIngredientUnit
    }

/********************************************************
    View setting Up part
********************************************************/
    func setUpViews() {
        setUpImage()
        quantityValue.inputAccessoryView = setUpPickerToolBar()
        quantityValue.inputView = quantityPickerView
        quantityValue.text = String(dietItem.quantity)
        if dietItem.portionInfo.count == 0 {
             unitValue.text = "portion"
        } else {
             unitValue.text = String(dietItem.portionInfo[dietItem.selectedPos].sizeUnit)
        }

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
        let alert = UIAlertController(title: "", message: "Please select preferred unit", preferredStyle: UIAlertControllerStyle.actionSheet)
        for (index, portion) in dietItem.portionInfo.enumerated() {
            alert.addAction(UIAlertAction(title: portion.sizeUnit, style: UIAlertActionStyle.default, handler: { (_) in
                self.selectedPortionPos = index
                self.foodDiaryEntity.dietItems[0].selectedPos = index
                self.dietItem.selectedPos = index
                self.unitValue.text = portion.sizeUnit
                self.dietItem.displayUnit = portion.sizeUnit
                self.setUpFoodValue()
            }))
        }
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        if isUpdate {
            self.navigationItem.rightBarButtonItem?.title = StringConstants.UIString.updateBtnText
        } else {
            self.navigationItem.rightBarButtonItem?.title = StringConstants.UIString.saveBtnText
        }
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }

    override func viewDidAppear(_ animated: Bool) {
        //move indicator to correct position
        UIView.animate(withDuration: 0.1, delay: 0.1, usingSpringWithDamping: 0.0, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.animationView.center.x = CGFloat(Float(self.currentMealIndex)*Float(80)) + CGFloat(10)
        })
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
        for index in 0...20 {
            quantityIntegerArray.append(index)
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
        if isUpdate {
            if let navigator = self.navigationController {
                for vc in (navigator.viewControllers) {
                    if let foodDiaryVC = vc as? FoodDiaryViewController {
                        foodDiaryVC.isSetMealByTimeRequired = self.isSetMealByTimeRequired
                        foodDiaryVC.updateFoodInfoItem(dietItem: dietItem)
                        foodDiaryVC.calculateAccumulateFoodValue()
                    }
                }
                navigator.popViewController(animated: true)
            }
        } else if recordType == RecognitionInteger.additionText {
            //1.multiple times TextSearchItem 2.first time TextSearchItem
            if let dest = UIStoryboard(name: "AddFoodScreen", bundle: nil).instantiateViewController(withIdentifier: "FoodDiaryVC") as? FoodDiaryViewController {
                dest.isUpdate = false
                dest.isSetMealByTimeRequired = false
                if let navigator = self.navigationController {
                    //pop otherView
                    if navigator.viewControllers.contains(where: {
                        return $0 is FoodDiaryViewController
                    }) {
                        //add foodItem into foodDiaryVC
                        for vc in (self.navigationController?.viewControllers)! {
                            if let foodDiaryVC = vc as? FoodDiaryViewController {
                                foodDiaryVC.addFoodIntoItem(dietItem: dietItem)
                                foodDiaryVC.calculateAccumulateFoodValue()
                                navigator.popToViewController(foodDiaryVC, animated: true)
                            }
                        }
                        //pop searchView & foodInfoView back to
//                        navigator.popViewController(animated: false)
//                        navigator.popViewController(animated: true)
                    } else {
                        //firstTime
                        dest.imageKey = imageKey
                        dest.userFoodImage = userFoodImage
                        dest.foodDiaryEntity = foodDiaryEntity
                        //pop searchView & foodInfoView
                        navigator.popViewController(animated: false)
                        navigator.popViewController(animated: false)
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
                        dest.selectedDate = DateUtil.normalStringToDate(dateStr: self.foodDiaryEntity.mealTime)
                        if let navigator = self.navigationController {
                            //pop all the view except HomePage
                            if navigator.viewControllers.contains(where: {
                                return $0 is FoodCalendarViewController
                            }) {
                                //add foodItem into foodDiaryVC
                                for vc in (self.navigationController?.viewControllers)! {
                                    if let foodCalendarVC = vc as? FoodCalendarViewController {
                                        navigator.popToViewController(foodCalendarVC, animated: true)
                                    }
                                }
                            } else {
                                navigator.popToRootViewController(animated: false)
                                navigator.pushViewController(dest, animated: true)
                            }
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
            containerTopConstraints.constant = self.view.frame.height - keyboardHeight - self.portionDataView.frame.size.height - CGFloat(60)
//            self.container.frame.origin.y = self.view.frame.height - keyboardHeight - self.portionDataView.frame.size.height
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                UIView.animate(withDuration: 0.2 ) {
                    self.portionDataView.frame.origin.y = CGFloat(0)
                }
            }
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        containerTopConstraints.constant = 291
//        self.container.frame.origin.y = foodSampleImage.frame.origin.y + foodSampleImage.frame.size.height + CGFloat(4)
        self.portionDataView.frame.origin.y =  nutritionDataView.frame.origin.y + nutritionDataView.frame.size.height + CGFloat(4)
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

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            currentIntegerPos = row
        } else {
            currentDecimalPos = row
        }
        quantityValue.text = String(Double(quantityIntegerArray[currentIntegerPos]) + decimalArray[currentDecimalPos])
        setUpFoodValue()
    }
}

extension FoodInfoViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mealStringArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mealTypeCell", for: indexPath) as? MealTypeCollectionCell {
                cell.setUpCell(isHightLight: false, mealStr: mealStringArray[indexPath.row])
                return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //change the mealType block selection
        currentMealIndex = indexPath.row
        foodDiaryEntity.mealType = mealStringArray[indexPath.row]
        //switch collection selection
        let destX = collectionView.cellForItem(at: indexPath)?.center.x
        UIView.animate(withDuration: 0.2, delay: 0.1, usingSpringWithDamping: 0.0, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.animationView.center.x = destX! + 50
        })
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CGFloat(70), height: CGFloat(32))
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
            quantityPickerView.selectRow(currentIntegerPos, inComponent: 0, animated: false)
            quantityPickerView.selectRow(currentDecimalPos, inComponent: 1, animated: false)
            return true
        } else if textField == unitValue {
            return false
        }
        return false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == quantityValue && !(quantityValue.text?.isEmpty)! {
            dietItem.quantity = Double(quantityValue.text!)!
            foodDiaryEntity.dietItems[0].quantity = Double(quantityValue.text!)!
            setUpFoodValue()
        }
    }

}
