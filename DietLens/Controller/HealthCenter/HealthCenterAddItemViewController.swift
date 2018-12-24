//
//  AddHealthItemViewCOntroller.swift
//  DietLens
//
//  Created by linby on 2018/6/29.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class HealthCenterAddItemViewController: UIViewController {
    //recordType
    var recordType = ""
    var recordName = ""
    //component
    @IBOutlet weak var addItemTableView: UITableView!
    //3 type of input dialog(UISlider,ruler,keyboard)
    var dateStr = ""
    var timeStr = ""
    var itemValue: Double = 0.0
    var unit = ""
    //picker view
    var datePickerView: UIDatePicker!
    var timePickerView: UIDatePicker!
    var rulerInputView: RulerInputView!
    var emojiInputView: EmojiInputView!

    var lastIndexPathRow = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        addItemTableView.delegate = self
        addItemTableView.dataSource  = self
        addItemTableView.tableFooterView = UIView()
        setUpPickerView()
        hideKeyboardWhenTappedAround()
    }

    func setUpPickerView() {
        datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .date
        datePickerView.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        timePickerView = UIDatePicker()
        timePickerView.datePickerMode = .time
        timePickerView.addTarget(self, action: #selector(timeChanged(_:)), for: .valueChanged)
    }

    @objc func dateChanged(_ sender: UIDatePicker) {
        let componenets = Calendar.current.dateComponents([.year, .month, .day], from: sender.date)
        if let day = componenets.day, let month = componenets.month, let year = componenets.year {
            //set data into component
            let indxPath = IndexPath(row: 1, section: 0)
            if let dateCell = addItemTableView.cellForRow(at: indxPath) as? HealthCenterTableValueCell {
                dateStr = "\(year)-\(month)-\(day)"
                dateCell.healthCenterTextField.text = dateStr
            }
        }
    }

    @objc func timeChanged(_ sender: UIDatePicker) {
        let componenets = Calendar.current.dateComponents([.hour, .minute], from: sender.date)
        if let hour = componenets.hour, let min = componenets.minute {
            //set data into component
            let indxPath = IndexPath(row: 2, section: 0)
            if let dateCell = addItemTableView.cellForRow(at: indxPath) as? HealthCenterTableValueCell {
                timeStr = "\(hour):\(min)"
                dateCell.healthCenterTextField.text = timeStr
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        //add record name
        self.navigationItem.title = "Add " + recordName
        let textColor = UIColor(red: CGFloat(67/255), green: CGFloat(67/255), blue: CGFloat(67/255), alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: textColor, kCTFontAttributeName: UIFont(name: "PingFangSC-Regular", size: 18)!] as? [NSAttributedStringKey: Any]
        self.navigationItem.leftBarButtonItem =  UIBarButtonItem(image: #imageLiteral(resourceName: "Back Arrow"), style: .plain, target: self, action: #selector(onBackPressed))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1.0)
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        addRightNavigationButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        let rulerIndex = IndexPath(row: 0, section: 0)
        if let valueCell = addItemTableView.cellForRow(at: rulerIndex) as? HealthCenterTableValueCell {
            valueCell.healthCenterTextField.becomeFirstResponder()
        }
    }

    @objc func onBackPressed() {
        view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }

    func addRightNavigationButton() {
        let rightNavButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(addHealthItem))
        rightNavButton.tintColor = UIColor(red: 94/255, green: 94/255, blue: 94/255, alpha: 1)
        self.navigationItem.rightBarButtonItem = rightNavButton
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }

    func setUpPickerToolBar(text: String) -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.barTintColor = UIColor.white
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 94/255, green: 94/255, blue: 94/255, alpha: 1)
        toolBar.sizeToFit()
        let textButton = UIBarButtonItem(title: text, style: UIBarButtonItemStyle.plain, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker))
        doneButton.setBackgroundImage(#imageLiteral(resourceName: "RedOvalBackgroundImage"), for: .normal, barMetrics: UIBarMetrics.default)
        doneButton.width = CGFloat(56)
        doneButton.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.white, kCTFontAttributeName as NSAttributedStringKey: UIFont(name: "PingFangSC-Regular", size: 16)!], for: .normal)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([textButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        return toolBar
    }

    @objc func donePicker() {
        view.endEditing(true)
        //set current value
        let indexPath = IndexPath(row: 0, section: 0)
        if let cell = addItemTableView.cellForRow(at: indexPath) as? HealthCenterTableValueCell {
            if let inputView =  cell.healthCenterTextField.inputView as? RulerInputView {
                let returnValue = Float(inputView.rulerView.getCurrentIndex())/Float(inputView.rulerView.divisor)
                cell.healthCenterTextField.text = String(returnValue) + unit
                itemValue = Double(returnValue)
            }
            if let inputView =  cell.healthCenterTextField.inputView as? EmojiInputView {
                let index = Int(inputView.emojiSlider.value)
                cell.healthCenterTextField.text = HealthCenterConstants.moodList[index]
                itemValue = Double(index)
            }
            //judge the filling value
            if !(cell.healthCenterTextField.text?.isEmpty)! {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }

    }

    @objc func addHealthItem() {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        appdelegate.showLoadingDialog()
        let recordValue = Double(round(1000*itemValue)/1000) //round value
        APIService.instance.uploadHealthCenterData(category: recordName, value: recordValue, date: dateStr, time: timeStr) { (isSuccess) in
            appdelegate.dismissLoadingDialog()
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            if isSuccess {
                self.navigationController?.popViewController(animated: true)
            } else {
                AlertMessageHelper.showMessage(targetController: self, title: "", message: "add Health log failed")
            }
        }
    }

}

extension HealthCenterAddItemViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3//value,date,time
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "healthCenterAddItemTableCell") as? HealthCenterTableValueCell else {
            return UITableViewCell()
        }
        switch indexPath.row {
        case 0:
            //value
            let capitalName = recordName.capitalizingFirstLetter()
            cell.healthCenterLabel.text = capitalName
            if recordType == "2"{ //emoji ruler
                let emojiInputView = EmojiInputView(frame: CGRect(x: 0, y: 0, width: 0, height: 220))
                cell.healthCenterTextField.inputAccessoryView = setUpPickerToolBar(text: "Mood")
                emojiInputView.delegate = self
                //set initial value
                emojiInputView.emojiSlider.value = 4
                emojiInputView.emojiLabel.text = HealthCenterConstants.moodList[4]
                emojiInputView.onEmojiValueChange(emojiInputView.emojiSlider)
                cell.healthCenterTextField.inputView = emojiInputView
                //set first one as default mood
                cell.healthCenterTextField.delegate = self
                cell.healthCenterTextField.text = HealthCenterConstants.moodList[4]
            } else if recordType == "1" { //weight ruler
                let glucoseInputView = RulerInputView(frame: CGRect(x: 0, y: 0, width: 0, height: 220), divisor: 10, max: HealthDeviceSetting.maxBloodGlucose, min: HealthDeviceSetting.minBloodGlucose)
                self.unit = "mmol/L"
                glucoseInputView.decimalDivisor = 10
                glucoseInputView.rulerView.setCurrentItem(position: HealthCenterConstants.GLUCOSEDEFAULT, animated: false)
                glucoseInputView.unit = "mmol/L"
                glucoseInputView.textLabel.text = "\(HealthCenterConstants.GLUCOSEDEFAULT/10)mmol/L"
                glucoseInputView.delegate = self
                cell.healthCenterTextField.inputAccessoryView = setUpPickerToolBar(text: "Blood glucose")
                cell.healthCenterTextField.delegate = self
                cell.healthCenterTextField.inputView = glucoseInputView
            } else { // glucose ruler
                let weightInputView = RulerInputView(frame: CGRect(x: 0, y: 0, width: 0, height: 220), divisor: 1, max: HealthDeviceSetting.maxWeight, min: HealthDeviceSetting.minWeight)
                 weightInputView.rulerView.setCurrentItem(position: HealthCenterConstants.WEIGHTDEFAULT, animated: false)
                self.unit = "kg"
                weightInputView.unit = "kg"
                weightInputView.textLabel.text = "\(HealthCenterConstants.WEIGHTDEFAULT)kg"
                weightInputView.delegate = self
                cell.healthCenterTextField.inputAccessoryView = setUpPickerToolBar(text: "Weight")
                cell.healthCenterTextField.delegate = self
                cell.healthCenterTextField.inputView = weightInputView
            }
            return cell
        case 1:
            //date
            cell.healthCenterTextField.placeholder = ""
            cell.healthCenterTextField.delegate = self
            cell.healthCenterLabel.text = "Date"
            cell.healthCenterTextField.inputAccessoryView = setUpPickerToolBar(text: "Date")
            cell.healthCenterTextField.inputView = datePickerView
            dateStr = DateUtil.normalDateToString(date: Date())
            cell.healthCenterTextField.text = dateStr
            return cell
        case 2:
            //time
            cell.healthCenterTextField.placeholder = ""
            cell.healthCenterTextField.delegate = self
            cell.healthCenterLabel.text = "Time"
            cell.healthCenterTextField.inputAccessoryView = setUpPickerToolBar(text: "Time")
            cell.healthCenterTextField.inputView = timePickerView
            timeStr = DateUtil.hourMinDateToString(date: Date())
            cell.healthCenterTextField.text = timeStr
            return cell
        default:
            break
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let lastIndexPath = IndexPath(row: lastIndexPathRow, section: 0)
        if let cell = tableView.cellForRow(at: lastIndexPath) as? HealthCenterTableValueCell {
            cell.healthCenterTextField.textColor = UIColor(red: CGFloat(67.0/255.0), green: CGFloat(67.0/255.0), blue: CGFloat(67.0/255.0), alpha: 1.0)
        }
        if let cell = tableView.cellForRow(at: indexPath) as? HealthCenterTableValueCell {
            cell.healthCenterTextField.becomeFirstResponder()
            cell.healthCenterTextField.textColor = UIColor(red: CGFloat(240.0/255.0), green: CGFloat(90.0/255.0), blue: CGFloat(90.0/255.0), alpha: 1.0)
        }
        lastIndexPathRow = indexPath.row
    }

}

extension HealthCenterAddItemViewController: UITextFieldDelegate {

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.cut(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}

extension HealthCenterAddItemViewController: RulerInputDelegate {

    func onRulerDidSelectItem(tag: Int, value: Double) {
        let rulerIndex = IndexPath(row: 0, section: 0)
        if let valueCell = addItemTableView.cellForRow(at: rulerIndex) as? HealthCenterTableValueCell {
            valueCell.healthCenterTextField.text = String(value) + unit
            itemValue = Double(value)
            //judge the filling value
            if !(valueCell.healthCenterTextField.text?.isEmpty)! {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }

    }
}

extension HealthCenterAddItemViewController: EmojiInputDelegate {

    func onEmojiDidSelectItem(index: Int) {
        let indexPath = IndexPath(row: 0, section: 0)
        if let cell = addItemTableView.cellForRow(at: indexPath) as? HealthCenterTableValueCell {
            cell.healthCenterTextField.text = HealthCenterConstants.moodList[index]
            itemValue = Double(index)
            //judge the filling value
            if !(cell.healthCenterTextField.text?.isEmpty)! {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }

    }
}

extension HealthCenterAddItemViewController {

    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
