//
//  RegistrationSecondStepViewController.swift
//  DietLens
//
//  Created by linby on 2018/6/28.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
class RegistrationSecondStepViewController: UIViewController {
    @IBOutlet weak var TFDate: UITextField!
    var datePicker: UIDatePicker!
     //buttons
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var signInBtn: UIButton!
    //entity
    var profile = UserProfile()

    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        TFDate.inputAccessoryView = setUpPickerToolBar()
        TFDate.inputView = datePicker
    }

    func setUpPickerToolBar() -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.barTintColor = UIColor.white
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 94/255, green: 94/255, blue: 94/255, alpha: 1)
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker))
        doneButton.setBackgroundImage(#imageLiteral(resourceName: "RedOvalBackgroundImage"), for: .normal, barMetrics: UIBarMetrics.default)
        doneButton.width = CGFloat(56)
        doneButton.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.white, kCTFontAttributeName as NSAttributedStringKey: UIFont(name: "PingFangSC-Regular", size: 16)!], for: .normal)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        return toolBar
    }

    @objc func dateChanged(_ sender: UIDatePicker) {
        let componenets = Calendar.current.dateComponents([.year, .month, .day], from: sender.date)
        if let day = componenets.day, let month = componenets.month, let year = componenets.year {
            TFDate.text = "\(year)-\(month)-\(day)"
            profile.birthday = TFDate.text!
        }
    }

    @objc func donePicker() {
        TFDate.resignFirstResponder()
    }

    @IBAction func next(_ sender: UIButton) {
        //fill in data & jump to final
        if profile.birthday.isEmpty {
            return
        }
        if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegistrationVC3") as? RegistrationThirdStepViewController {
                dest.profile = profile
                self.navigationController?.pushViewController(dest, animated: true)
        }
    }

    @IBAction func skip(_ sender: UIButton) {
        if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegistrationVC3") as? RegistrationThirdStepViewController {
            dest.profile = profile
            self.navigationController?.pushViewController(dest, animated: true)
        }
    }

    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func toSignInPage(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}
