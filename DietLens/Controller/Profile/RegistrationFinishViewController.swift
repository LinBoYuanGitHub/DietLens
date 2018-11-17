//
//  RegistrationFinishPage.swift
//  DietLens
//
//  Created by linby on 2018/7/6.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
class RegistrationFinishViewController: UIViewController {

    @IBOutlet weak var calorieText: UILabel!
    @IBOutlet weak var registrationButton: UIButton!
    @IBOutlet weak var calorieGoalTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        getGoalCalorie()
        self.hideKeyboardWhenTappedAround()
    }

    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
        //navigation controller
        self.navigationController?.navigationBar.isHidden = false
        //        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Back Arrow"), style: .plain, target: self, action: #selector(onBackPressed))
        let textColor = UIColor(red: CGFloat(67/255), green: CGFloat(67/255), blue: CGFloat(67/255), alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: textColor, kCTFontAttributeName: UIFont(name: "PingFangSC-Regular", size: 18)!] as? [NSAttributedStringKey: Any]
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "Sign Up"
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }

    func getGoalCalorie() {
        APIService.instance.getDietaryGuideInfo { (guideDict) in
            if let calorie = guideDict["energy"] {
                self.calorieText.text = "\(Int(calorie))kcal"
            }
        }
    }

    @IBAction func onRegistrationBtnClicked(_ sender: Any) {
        //set registration profile filling flag to true
        let preference = UserDefaults.standard
//        preference.set(true, forKey: FirstTimeFlag.shouldPopUpProfilingDialo)
        preference.bool(forKey: FirstTimeFlag.shouldPopUpProfilingDialog)
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeTabNVC") as? UINavigationController {
           self.present(controller, animated: true, completion: nil)
        }
        //update the calorie value
        guard let calorieText = calorieGoalTextField.text else {
            return
        }
        guard let calorieValue = Double(calorieText) else {
            return
        }
        APIService.instance.setCalorieGoal(calorieGoal: calorieValue) { (isSuccess) in
            //handle the successful case
        }
    }

}

extension RegistrationFinishViewController {

    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
