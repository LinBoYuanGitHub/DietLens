//
//  ProfileCalorieGoalViewController.swift
//  DietLens
//
//  Created by linby on 2018/11/15.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

protocol CalorieGoalSetDelegate {
    func onCalorieGoalSet(goalValue: Int)
}

class ProfileCalorieGoalViewController: BaseViewController {
     var calorieGoalSetDelegate: CalorieGoalSetDelegate?
    //registration flow param
    var profile: UserProfile?
    var isInRegistrationFlow = false
    var calorieGoal: Int = 0

    @IBOutlet weak var recommendCalorieGoal: UILabel!
    @IBOutlet weak var calorieGoalField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        calorieGoalField.text = String(calorieGoal)
        calorieGoalField.keyboardType = .numberPad
        APIService.instance.getDietaryGuideInfo { (guideDict) in
            guard let calorieGoal = guideDict["energy"] else {
                return
            }
            self.recommendCalorieGoal.text = String(Int(calorieGoal)) + "kcal"
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //back btn
        self.navigationItem.leftBarButtonItem =  UIBarButtonItem(image: #imageLiteral(resourceName: "Back Arrow"), style: .plain, target: self, action: #selector(onBackPressed))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1.0)
        if isInRegistrationFlow {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(toHomePage))
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 67.0/255.0, green: 67.0/255.0, blue: 67.0/255.0, alpha: 1.0)
        }
        self.navigationItem.title = "Adjust Calories"
    }

    @objc func onBackPressed() {
        self.navigationController?.popViewController(animated: true)
        if !isInRegistrationFlow {
            guard let goal = Int(calorieGoalField.text ?? "") else {
                return
            }
            //update calorie goal API
            if Double(goal) < 1000 && Double(goal) > 4000 {
                AlertMessageHelper.showMessage(targetController: self, title: "", message: "")
                return
            }
            APIService.instance.setCalorieGoal(calorieGoal: Double(goal)) { (isSuccess) in
                if isSuccess {
                    self.calorieGoalSetDelegate?.onCalorieGoalSet(goalValue: goal)
                }
            }
        }
    }

    @objc func toHomePage() {
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeTabNVC") as? UINavigationController {
            self.present(controller, animated: true, completion: nil)
        }
    }

}

extension ProfileCalorieGoalViewController {

    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProfileCalorieGoalViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

}
