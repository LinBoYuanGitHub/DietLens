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

    var quantityPicker: UIPickerView!
    var unitPicker: UIPickerView!

    var ingredient: Ingredient!

    var quantity = ["0", "1", "2", "3", "4", "5"]
    var decimal = ["0", "1/2", "1/4", "1/8"]
    var decimalValues = [0, 0.5, 0.25, 0.125]
    var nutrtitions = [String]()

    var ingredientDiary = IngredientDiary()

    var quantityIndex = 1
    var decimalIndex = 0

    override func viewDidLoad() {
        ingredientNameLabel.text = ingredient?.long_desc
        unitTextField.text = ingredient?.ingredientUnit[0].unit
        nutritionTable.delegate = self
        nutritionTable.dataSource = self
        nutritionTable.tableHeaderView = tableHeader
        setUpPickerView()
        quantityTextField.inputView = quantityPicker
        quantityTextField.inputAccessoryView = setUpPickerToolBar()
        unitTextField.inputView = unitPicker
        unitTextField.inputAccessoryView = setUpPickerToolBar()
        calculateNutrtions()
        //set up diary basic
        ingredientDiary.ingredientId = ingredient.ingredientId
        ingredientDiary.ingredientName = ingredient.long_desc
    }

    func calculateNutrtions() {
        let quantityIndex = quantityPicker.selectedRow(inComponent: 0)
        let decimalIndex = quantityPicker.selectedRow(inComponent: 1)
        let unitIndex = unitPicker.selectedRow(inComponent: 0)
        let rate = (Double(quantity[quantityIndex])!+decimalValues[decimalIndex])*Double(ingredient.ingredientUnit[unitIndex].weight)!/100
        ingredientDiary.weight = Double(ingredient.ingredientUnit[unitIndex].weight)!
        ingredientDiary.quantity = Double(quantity[quantityIndex])!+decimalValues[decimalIndex]
        ingredientDiary.unit = ingredient.ingredientUnit[unitIndex].unit
        ingredientDiary.calorie = Double(ingredient.energy_kcal)!*rate
        ingredientDiary.carbs = Double(ingredient.carbs)!*rate
        ingredientDiary.protein = Double(ingredient.protein)!*rate
        ingredientDiary.fat = Double(ingredient.fat)!*rate
        ingredientDiary.sugars_total = Double(ingredient.sugars_total)!*rate
        //round decimal
        ingredientDiary.calorie = round(10*ingredientDiary.calorie)/10
        ingredientDiary.carbs = round(10*ingredientDiary.carbs)/10
        ingredientDiary.protein = round(10*ingredientDiary.protein)/10
        ingredientDiary.fat = round(10*ingredientDiary.fat)/10
        //set value for nutritions
        nutrtitions = ["calories  "+String(ingredientDiary.calorie)+"g", "carbs  "+String(ingredientDiary.carbs)+"g", "protein  "+String(ingredientDiary.protein)+"g", "fat  "+String(ingredientDiary.fat)+"g", "sugarTotal  "+String(ingredientDiary.sugars_total)+"g"]
        nutritionTable.reloadData()
    }

    func setUpPickerView() {
        quantityPicker = UIPickerView()
        unitPicker = UIPickerView()
        quantityPicker.delegate = self
        quantityPicker.dataSource = self
        quantityPicker.showsSelectionIndicator = true
        quantityPicker.accessibilityViewIsModal = true
        quantityPicker.selectRow(1, inComponent: 0, animated: false)
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
        if(quantityIndex == 0 && decimalIndex == 0) {
            AlertMessageHelper.showMessage(targetController: self, title: "", message: "please choose a quantity greater than zero")
            return
        }
        //back to recogniton view
        let parent = presentingViewController
        dismiss(animated: false, completion: {
            parent!.dismiss(animated: true, completion: nil)
        })
        //send notification to add ingredient
        let dataDict: [String: IngredientDiary] = ["ingredientdiary": ingredientDiary]
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
        if pickerView == quantityPicker {
            if component == 0 {
                return quantity.count
            } else {
                return decimal.count
            }
        } else if pickerView == unitPicker {
            return (ingredient?.ingredientUnit.count)!
        }
        return 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == quantityPicker {
            if component == 0 {
                return quantity[row]
            } else {
                return decimal[row]
            }
        } else if pickerView == unitPicker {
            return ingredient?.ingredientUnit[row].unit
        }
        return ""
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //set textField text & calculate unit nutrtion
        if pickerView == quantityPicker {
            if component == 0 {
                quantityIndex = row
            } else {
                decimalIndex = row
            }
            if (quantityIndex == 0 && decimalIndex == 0) {
                quantityTextField.text = "0"
            } else if(decimalIndex == 0) {
                quantityTextField.text = quantity[quantityIndex]
            } else if(quantityIndex == 0) {
                quantityTextField.text = decimal[decimalIndex]
            } else {
                 quantityTextField.text = quantity[quantityIndex] + " and " + decimal[decimalIndex]
            }
            calculateNutrtions()
        } else if pickerView == unitPicker {
            unitTextField.text = ingredient?.ingredientUnit[row].unit
            calculateNutrtions()
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == quantityPicker {
            return 2
        } else {
             return 1
        }
    }

}
