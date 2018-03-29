//
//  AddIngredientViewController.swift
//  DietLens
//
//  Created by linby on 18/01/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class AddIngredientViewController: UIViewController {
    @IBOutlet weak var ingredientNameLabel: UILabel!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var unitTextField: UITextField!
    @IBOutlet weak var nutritionTable: UITableView!
    @IBOutlet weak var tableHeader: UIStackView!

    var unitPicker: UIPickerView!

    var ingredient: Ingredient!

    var nutrtitions = [String]()

    var ingredientDiary = IngredientDiary()

    override func viewDidLoad() {
        self.hideKeyboardWhenTappedAround()
        ingredientNameLabel.text = ingredient?.longDesc
        quantityTextField.keyboardType = UIKeyboardType.decimalPad
        quantityTextField.delegate = self
        unitTextField.text = ingredient?.ingredientUnit[0].unit
        nutritionTable.delegate = self
        nutritionTable.dataSource = self
        nutritionTable.tableHeaderView = tableHeader
        setUpPickerView()
        unitTextField.inputView = unitPicker
        unitTextField.inputAccessoryView = setUpPickerToolBar()
        calculateNutrtions()
        //set up diary basic
        ingredientDiary.ingredientId = ingredient.ingredientId
        ingredientDiary.ingredientName = ingredient.longDesc
    }

    func calculateNutrtions() {
        let unitIndex = unitPicker.selectedRow(inComponent: 0)
        let rate = Double(quantityTextField.text!)!*Double(ingredient.ingredientUnit[unitIndex].weight)!/100
        ingredientDiary.weight = Double(ingredient.ingredientUnit[unitIndex].weight)!
        ingredientDiary.quantity = Double(quantityTextField.text!)!
        ingredientDiary.unit = ingredient.ingredientUnit[unitIndex].unit
        ingredientDiary.calorie = Double(ingredient.energyKcal)!*rate
        ingredientDiary.carbs = Double(ingredient.carbs)!*rate
        ingredientDiary.protein = Double(ingredient.protein)!*rate
        ingredientDiary.fat = Double(ingredient.fat)!*rate
        ingredientDiary.sugarsTotal = Double(ingredient.sugarsTotal)!*rate
        //round decimal
        ingredientDiary.calorie = round(10*ingredientDiary.calorie)/10
        ingredientDiary.carbs = round(10*ingredientDiary.carbs)/10
        ingredientDiary.protein = round(10*ingredientDiary.protein)/10
        ingredientDiary.fat = round(10*ingredientDiary.fat)/10
        //set value for nutritions
        nutrtitions = [NutrtionData.calorieText+"  "+String(ingredientDiary.calorie)+"g", NutrtionData.carbohydrateText+"  "+String(ingredientDiary.carbs)+"g", NutrtionData.proteinText+"  "+String(ingredientDiary.protein)+"g", NutrtionData.fatText+"  "+String(ingredientDiary.fat)+"g"]
        //, NutrtionData.sugarText+"  "+String(ingredientDiary.sugarsTotal)+"g"]
        nutritionTable.reloadData()
    }

    func setUpPickerView() {
        unitPicker = UIPickerView()
        unitPicker.delegate = self
        unitPicker.dataSource = self
        unitPicker.showsSelectionIndicator = true
        unitPicker.accessibilityViewIsModal = true
    }

    func setUpPickerToolBar() -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: "donePicker")
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)

        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        return toolBar
    }

    @objc func donePicker() {
        quantityTextField.resignFirstResponder()
        unitTextField.resignFirstResponder()
    }
    @IBAction func onBackPressed() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func performAddIngredient(_ sender: Any) {
        let quantity = Double(quantityTextField.text!)!
        if(quantity<1.0) {
            AlertMessageHelper.showMessage(targetController: self, title: "", message: "please choose a quantity greater than zero")
            return
        }
        calculateNutrtions()
        //back to recogniton view
        let parent = presentingViewController
        dismiss(animated: false, completion: {
            parent!.dismiss(animated: true, completion: nil)
        })
        //send notification to add ingredient
        var diaryIngredientModel = IngredientDiaryModel()
        diaryIngredientModel.convertToObject(ingredientDiary: ingredientDiary)
        let dataDict: [String: IngredientDiaryModel] = ["ingredientdiary": diaryIngredientModel]
        NotificationCenter.default.post(name: .addIngredient, object: nil, userInfo: dataDict)
    }
}

extension AddIngredientViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nutrtitions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nutrtitions[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Nutritions"
    }

}

extension AddIngredientViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == unitPicker {
            return (ingredient?.ingredientUnit.count)!
        }
        return 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == unitPicker {
            return ingredient?.ingredientUnit[row].unit
        }
        return ""
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == unitPicker {
            unitTextField.text = ingredient?.ingredientUnit[row].unit
            calculateNutrtions()
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
             return 1
    }

}

extension AddIngredientViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text?.isEmpty)! {
            return
        }
        calculateNutrtions()
    }

}

extension AddIngredientViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddIngredientViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
