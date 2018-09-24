//
//  RegistrationProfileViewController.swift
//  DietLens
//
//  Created by linby on 2018/9/19.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class RegistrationProfileViewController: BaseViewController {

    @IBOutlet weak var profileTableView: UITableView!
    //dialog & picker
    var birthDayPickerView: UIDatePicker!
    var genderPickerView: UIPickerView!
    var ethnicityPickerView: UIPickerView!
    var weightPickerView: UIPickerView!
    var heightPickerView: UIPickerView!
    var genderList = ["Male", "Female", "Others"]
    var ethnicityList = ["Chinese", "Malays", "Indians", "Others"]
    var weightList = [Int]()
    var heightList = [Int]()
    //profile
    var profile = UserProfile()

    var lastIndexPathRow = 0

    override func viewDidLoad() {
        profileTableView.delegate = self
        profileTableView.dataSource = self
        profileTableView.tableFooterView = UIView()
        setUpListData()
        setUpPicker()
        hideKeyboardWhenTappedAround()
        //set initial timing
        birthDayPickerView.date = DateUtil.normalStringToDate(dateStr: "1990-01-01")
        profile.birthday = "1990-01-01"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "cross"), style: .plain, target: self, action: #selector(onCloseBtnPressed))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor(red: 67/255, green: 67/255, blue: 67/255, alpha: 1.0)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(onNextPressed))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 67/255, green: 67/255, blue: 67/255, alpha: 1.0)
        self.navigationItem.title = "Sign Up"
    }

    func setUpListData() {
        for index in HealthDeviceSetting.minHeight...HealthDeviceSetting.maxHeight {
            heightList.append(index)
        }
        for index in HealthDeviceSetting.minWeight...HealthDeviceSetting.maxWeight {
            weightList.append(index)
        }
    }

    func setUpPicker() {
        //birthday date picker
        birthDayPickerView = UIDatePicker()
        birthDayPickerView.datePickerMode = .date
        birthDayPickerView.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        setDateLimitation()
        //gender picker
        genderPickerView = UIPickerView()
        genderPickerView.showsSelectionIndicator = true
        genderPickerView.accessibilityViewIsModal = true
        genderPickerView.dataSource = self
        genderPickerView.delegate = self
        //ethnicity picker
        ethnicityPickerView = UIPickerView()
        ethnicityPickerView.dataSource = self
        ethnicityPickerView.delegate = self
        //Weight picker
        weightPickerView = UIPickerView()
        weightPickerView.dataSource = self
        weightPickerView.delegate = self
        //Height picker
        heightPickerView = UIPickerView()
        heightPickerView.dataSource = self
        heightPickerView.delegate = self
    }

    func setDateLimitation() {
        var minComp = DateComponents()
        minComp.year = -BirthDayLimitation.maxAge
        var maxComp = DateComponents()
        maxComp.year = -BirthDayLimitation.minAge
        let minDate = Calendar.current.date(byAdding: minComp, to: Date())
        let maxDate = Calendar.current.date(byAdding: maxComp, to: Date())
        birthDayPickerView.maximumDate = maxDate
        birthDayPickerView.minimumDate = minDate
    }

    @objc func dateChanged(_ sender: UIDatePicker) {
        let componenets = Calendar.current.dateComponents([.year, .month, .day], from: sender.date)
        if let day = componenets.day, let month = componenets.month, let year = componenets.year {
            //set data into component
            let indxPath = IndexPath(row: 2, section: 0)
            if let dateCell = profileTableView.cellForRow(at: indxPath) as? RegistrationProfileCell {
                let birthdayString = "\(year)-\(month)-\(day)"
                profile.birthday = birthdayString
                dateCell.registrationTextField.text = birthdayString
            }
        }
    }

    @objc func donePicker() {
        view.endEditing(true)
    }

    @objc func onNextPressed() {
        //judge for the field value
        var anyEmptyFlag = false
        for index in 0...5 {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = profileTableView.cellForRow(at: indexPath) as? RegistrationProfileCell {
                if (cell.registrationTextField.text?.isEmpty)! {
                    cell.registrationTextField.attributedPlaceholder = NSAttributedString(string: "This field is required",
                                                                                          attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
                    anyEmptyFlag = true
                }
            }
        }
        if anyEmptyFlag {
            return
        }
        if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "activityLevelVC") as? ProfileActivityLvlViewController {
            dest.profile = self.profile
            dest.isInRegistrationFlow = true
            self.navigationController?.pushViewController(dest, animated: true)
        }
    }

    @objc func onCloseBtnPressed() {
        //redirect to main page, need to have filling profile reminder
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "sideLGMenuVC")
        self.present(viewController, animated: true, completion: nil)
    }

}

extension RegistrationProfileViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            profile.name = textField.text!
        }
        textField.textColor = UIColor(red: 67.0/255.0, green: 67.0/255.0, blue: 67.0/255.0, alpha: 1)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.textColor = UIColor(red: 243.0/255.0, green: 70.0/255.0, blue: 90.0/255.0, alpha: 1)
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.cut(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}

extension RegistrationProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == weightPickerView || pickerView == heightPickerView {
            return 2
        } else {
            return 1
        }
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == genderPickerView {
            return genderList.count
        } else if pickerView == ethnicityPickerView {
            return ethnicityList.count
        } else if pickerView == heightPickerView {
            if component == 0 {
                return heightList.count
            } else {
                return 1
            }
        } else if pickerView == weightPickerView {
            if component == 0 {
                return weightList.count
            } else {
                return 1
            }
        }
        return 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == genderPickerView {
            return genderList[row]
        } else if pickerView == ethnicityPickerView {
            return ethnicityList[row]
        } else if pickerView == heightPickerView {
            if component == 0 {
                return String(heightList[row])
            } else {
                return "cm"
            }
        } else if pickerView == weightPickerView {
            if component == 0 {
                return String(weightList[row])
            } else {
                return "kg"
            }
        }
        return ""
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == genderPickerView {
            let indexPath = IndexPath(row: 1, section: 0)
            if let dateCell = profileTableView.cellForRow(at: indexPath) as? RegistrationProfileCell {
                dateCell.registrationTextField.text = genderList[row]
                profile.gender = row + 1
            }
        } else if pickerView == ethnicityPickerView {
            let indexPath = IndexPath(row: 3, section: 0)
            if let dateCell = profileTableView.cellForRow(at: indexPath) as? RegistrationProfileCell {
                dateCell.registrationTextField.text = ethnicityList[row]
                profile.ethnicity = row + 1
            }
        } else if pickerView == weightPickerView {
            let indexPath = IndexPath(row: 4, section: 0)
            if let dateCell = profileTableView.cellForRow(at: indexPath) as? RegistrationProfileCell {
                dateCell.registrationTextField.text = String(weightList[row]) + "kg"
                profile.weight = Double(weightList[row])
            }
        } else if pickerView == heightPickerView {
            let indexPath = IndexPath(row: 5, section: 0)
            if let dateCell = profileTableView.cellForRow(at: indexPath) as? RegistrationProfileCell {
                dateCell.registrationTextField.text = String(heightList[row]) + "cm"
                profile.height = Double(heightList[row])
            }
        }
    }

}

extension RegistrationProfileViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "registrationProfileCell", for: indexPath) as? RegistrationProfileCell else {
             return UITableViewCell()
        }
        //common setting
        cell.registrationTextField.placeholder = "Not set"
        cell.registrationTextField.textColor = .black
        cell.registrationTextField.delegate = self
        switch indexPath.row {
        case 0:
            cell.setUpCell(fieldName: "Nickname")
            cell.registrationTextField.keyboardType = .asciiCapable
            cell.registrationTextField.tag = 1
        case 1:
            cell.setUpCell(fieldName: "Gender")
            cell.registrationTextField.text = genderList[0]
            cell.registrationTextField.inputView = genderPickerView
        case 2:
            cell.setUpCell(fieldName: "Date of birth")
            cell.registrationTextField.text = profile.birthday
            cell.registrationTextField.inputView = birthDayPickerView
        case 3:
            cell.setUpCell(fieldName: "Ethnicity")
            cell.registrationTextField.text = ethnicityList[0]
            cell.registrationTextField.inputView = ethnicityPickerView
        case 4:
            cell.setUpCell(fieldName: "Weight")
            cell.registrationTextField.inputView = weightPickerView
            cell.registrationTextField.text = "60kg"
            profile.weight = 60
            weightPickerView.selectRow(60-HealthDeviceSetting.minWeight, inComponent: 0, animated: false)
        case 5:
            cell.setUpCell(fieldName: "Height")
            cell.registrationTextField.inputView = heightPickerView
            cell.registrationTextField.text = "170cm"
            profile.height = 170
            heightPickerView.selectRow(170-HealthDeviceSetting.minHeight, inComponent: 0, animated: false)
        default:
            break
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath) as? RegistrationProfileCell {
            cell.registrationTextField.becomeFirstResponder()
            if cell.registrationTextField.inputView == genderPickerView {
                cell.registrationTextField.text = genderList[0]
            } else if cell.registrationTextField.inputView == ethnicityPickerView {
                cell.registrationTextField.text = ethnicityList[0]
            }
        }
//        //lastIndexPathRow
//        let lastIndexPath = IndexPath(row: lastIndexPathRow, section: 0)
//        if let cell = tableView.cellForRow(at: lastIndexPath) as? RegistrationProfileCell {
//            cell.registrationTextField.textColor = UIColor(red: 67.0/255.0, green: 67.0/255.0, blue: 67.0/255.0, alpha: 1)
//        }
//        if let cell = tableView.cellForRow(at: indexPath) as? RegistrationProfileCell {
//            cell.registrationTextField.becomeFirstResponder()
//            cell.registrationTextField.textColor = UIColor(red: 243.0/255.0, green: 70.0/255.0, blue: 90.0/255.0, alpha: 1)
//        }
//        lastIndexPathRow = indexPath.row
    }

}

extension RegistrationProfileViewController {

    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RegistrationProfileViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func setAttributeText(textStr: String, textField: UITextField) {
        let textAttr = NSMutableAttributedString.init(string: textStr)
        textAttr.setAttributes([ kCTForegroundColorAttributeName as NSAttributedStringKey: UIColor.gray, NSAttributedStringKey.font: UIFont(name: "PingFangSC-Light", size: 14.0) as Any
            ], range: NSRange(location: textStr.count - 2, length: 2))
        textField.attributedText = textAttr
    }
}
