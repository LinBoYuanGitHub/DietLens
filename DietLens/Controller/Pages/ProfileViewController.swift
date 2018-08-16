//
//  ProfileViewController.swift
//  DietLens
//
//  Created by next on 10/11/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var TFName: UITextField!
    @IBOutlet weak var TFGender: UITextField!
    @IBOutlet weak var TFHeight: UITextField!
    @IBOutlet weak var TFWeight: UITextField!
    @IBOutlet weak var TFAge: UITextField!

    var genderPickerView: UIPickerView!
    var birthDayPickerView: UIDatePicker!
    var genderList = ["male", "female"]

    var isRegister = false

    override func viewDidLoad() {
        super.viewDidLoad()
        TFName.delegate = self
        TFName.tag = 1
        TFGender.delegate = self
        TFGender.tag = 2
        TFHeight.delegate = self
        TFHeight.keyboardType = .decimalPad
        TFHeight.tag = 3
        TFWeight.delegate = self
        TFWeight.keyboardType = .decimalPad
        TFWeight.tag = 4
        TFAge.keyboardType = .numberPad
        TFAge.delegate = self
        TFAge.tag = 5
        //set up gender picker
        setUpPickerView()
        let genderPickerToolBar = setUpPickerToolBar(textField: TFGender)
        let heightPickerToolBar = setUpPickerToolBar(textField: TFHeight)
        let weightPickerToolBar = setUpPickerToolBar(textField: TFWeight)
        let agePickerToolBar =
            setUpPickerToolBar(textField: TFAge)
        TFGender.inputView = genderPickerView
        TFAge.inputView = birthDayPickerView
        TFGender.inputAccessoryView = genderPickerToolBar
        TFHeight.inputAccessoryView = heightPickerToolBar
        TFWeight.inputAccessoryView = weightPickerToolBar
        TFAge.inputAccessoryView = agePickerToolBar
        //load profie
        let preferences = UserDefaults.standard
        let key = "userId"
        let userId = preferences.string(forKey: key)
        AlertMessageHelper.showLoadingDialog(targetController: self)
        APIService.instance.getProfile(userId: userId!) { (userProfile) in
            AlertMessageHelper.dismissLoadingDialog(targetController: self)
            //set userProfile
            if userProfile == nil {
                return
            }
            self.TFName.text = userProfile?.name
            self.TFWeight.text = String(format: "%.1f", userProfile!.weight)
            self.TFHeight.text = String(format: "%.1f", userProfile!.height)
            self.TFAge.text = "\(userProfile!.birthday)"
            if userProfile?.gender == 0 {
                self.TFGender.text = self.genderList[1]
                self.genderPickerView.selectRow(1, inComponent: 0, animated: false)
            } else if userProfile?.gender == 1 {
                self.TFGender.text = self.genderList[0]
                self.genderPickerView.selectRow(0, inComponent: 0, animated: false)
            } else {
                self.TFGender.text = ""
            }
            let birthDate = DateUtil.normalStringToDate(dateStr: (userProfile?.birthday)!)
            self.birthDayPickerView.setDate(birthDate, animated: false)
        }
        //setTouch to dismiss keyboard
        hideKeyboardWhenTappedAround()
    }

    func setUpPickerView() {
        genderPickerView = UIPickerView()
        genderPickerView.dataSource = self
        genderPickerView.delegate = self
        genderPickerView.showsSelectionIndicator = true
        genderPickerView.accessibilityViewIsModal = true
        birthDayPickerView = UIDatePicker()
        birthDayPickerView.datePickerMode = .date
        birthDayPickerView.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
    }

    @objc func dateChanged(_ sender: UIDatePicker) {
        let componenets = Calendar.current.dateComponents([.year, .month, .day], from: sender.date)
        if let day = componenets.day, let month = componenets.month, let year = componenets.year {
            TFAge.text = "\(year)-\(month)-\(day)"
        }
    }

    func setUpPickerToolBar(textField: UITextField) -> UIToolbar {
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
        if TFGender.isFirstResponder {
            //set selectValue
            TFGender.text = genderList[genderPickerView.selectedRow(inComponent: 0)]
            TFGender.resignFirstResponder()
            //            TFHeight.becomeFirstResponder()
        } else if TFHeight.isFirstResponder {
            TFHeight.resignFirstResponder()
            keyboardWillHide()
            //            TFWeight.becomeFirstResponder()
        } else if TFWeight.isFirstResponder {
            TFWeight.resignFirstResponder()
            keyboardWillHide()
            //            TFAge.becomeFirstResponder()
        } else {
            TFAge.resignFirstResponder()
            keyboardWillHide()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    func keyboardWillShow() {
        if self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= (100)
        }
    }

    func keyboardWillHide() {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y += (100)
        }
    }

    @IBAction func updateProfile(_ sender: Any) {
        let preferences = UserDefaults.standard
        let key = "userId"
        let userId = preferences.string(forKey: key)
        var gender = 0
        if TFGender.text == "male"{
            gender = 1
        } else if TFGender.text == "female"{
            gender = 0
        } else {
            //TODO alert fill incomplete warning
            return
        }
        AlertMessageHelper.showLoadingDialog(targetController: self)
        APIService.instance.updateProfile(userId: userId!, name: TFName.text!, gender: gender, height: Double(TFHeight.text!)!, weight: Double(TFWeight.text!)!, birthday: TFAge.text!) { (isSuccess) in
            NotificationCenter.default.post(name: .shouldRefreshMainPageNutrition, object: nil)
            NotificationCenter.default.post(name: .shouldRefreshSideBarHeader, object: nil)
            //refresh the profile sharedPreference
            AlertMessageHelper.dismissLoadingDialog(targetController: self) {
                if isSuccess {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    //error alert
                    AlertMessageHelper.showMessage(targetController: self, title: "", message: "update profile failed")
                }
            }
        }
    }
}

extension ProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderList.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderList[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
      TFGender.text = genderList[row]
    }

}

extension ProfileViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == TFName {
            TFGender.becomeFirstResponder()
            TFGender.text = genderList[0]
        }
        return false
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if (textField == TFHeight || textField == TFWeight || textField == TFAge ) {
            keyboardWillShow()
        }
        return true
    }

}

extension ProfileViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
        keyboardWillHide()
    }
}
