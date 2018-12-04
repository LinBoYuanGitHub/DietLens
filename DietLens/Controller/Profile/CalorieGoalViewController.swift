//
//  RegistrationFinishPage.swift
//  DietLens
//
//  Created by linby on 2018/7/6.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

protocol CalorieGoalSetDelegate {
    func onCalorieGoalSet(goalValue: Int)
}

class CalorieGoalViewController: BaseViewController {

    @IBOutlet weak var registrationButton: UIButton!
    @IBOutlet weak var calorieGoalTextField: UITextField!
    @IBOutlet weak var recommendTextLabel: UILabel!
    @IBOutlet weak var thanksLabel: UILabel!

    var calorieGoalSetDelegate: CalorieGoalSetDelegate?
    var isInRegistrationFlow = false

    override func viewDidLoad() {
        super.viewDidLoad()
        calorieGoalTextField.keyboardType = .numberPad
        getGoalCalorie()
        thanksLabel.isHidden = !isInRegistrationFlow
        self.hideKeyboardWhenTappedAround()
    }

    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
        //navigation controller
        self.navigationController?.navigationBar.isHidden = false
        let textColor = UIColor(red: CGFloat(67/255), green: CGFloat(67/255), blue: CGFloat(67/255), alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: textColor, kCTFontAttributeName: UIFont(name: "PingFangSC-Regular", size: 18)!] as? [NSAttributedStringKey: Any]
        if isInRegistrationFlow {
             self.navigationItem.hidesBackButton = true
        }
        self.navigationItem.title = "Adjust Calories"
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        if isInRegistrationFlow {
            recommendTextLabel.text = "Your Recommended Calorie Goal:"
        } else {
            recommendTextLabel.text = "Your Calorie Goal is:"
            recommendTextLabel.font = recommendTextLabel.font.withSize(CGFloat(24))
        }
    }

    func getGoalCalorie() {
        APIService.instance.getDietGoal { (dietDict) in
            if let calorie = dietDict["energy"] {
                self.calorieGoalTextField.text = "\(Int(calorie))"
            }
        }
    }

    func getRecommendCalorie() {
        APIService.instance.getDietaryGuideInfo { (guideDict) in
            if let calorie = guideDict["energy"] {
                self.calorieGoalTextField.text = "\(Int(calorie))"
            }
        }
    }

    @IBAction func onRegistrationBtnClicked(_ sender: Any) {
        //set registration profile filling flag to true
        //update the calorie value
        guard let calorieText = calorieGoalTextField.text else {
            return
        }
        guard let calorieValue = Double(calorieText) else {
            return
        }
        if Int(calorieValue) < DietGoalTreshold.minCalorieGoalValue || Int(calorieValue) > DietGoalTreshold.maxCalorieGoalValue {
            AlertMessageHelper.showMessage(targetController: self, title: "", message: "Calorie goal must be between 1000 and 4000")
            return
        }
        let preference = UserDefaults.standard
        preference.bool(forKey: FirstTimeFlag.shouldPopUpProfilingDialog)
        APIService.instance.setCalorieGoal(calorieGoal: calorieValue) { (isSuccess) in
            if self.isInRegistrationFlow {
                if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeTabNVC") as? UINavigationController {
                    self.present(controller, animated: true, completion: nil)
                }
            } else {
                self.calorieGoalSetDelegate?.onCalorieGoalSet(goalValue: Int(calorieValue))
                NotificationCenter.default.post(name: .shouldRefreshMainPageNutrition, object: nil)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    @IBAction func onQuestionMarkClicked(_ sender: Any) {
        //show calorie goal alret
        let storyboard = UIStoryboard(name: "AddFoodScreen", bundle: nil)
        if let recommendCalorieAlert =  storyboard.instantiateViewController(withIdentifier: "RecommendCalorieDialogVC") as? RecommendCalorieGoalDialog {
            recommendCalorieAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            recommendCalorieAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            present(recommendCalorieAlert, animated: true, completion: nil)
        }
    }

    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension CalorieGoalViewController {

    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
