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

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func getGoalCalorie() {
        APIService.instance.getDietaryGuideInfo { (guideDict) in
            self.calorieText.text = "\(guideDict["energy"])kcal"
        }
    }

    @IBAction func onRegistrationBtnClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "sideLGMenuVC")
        self.present(viewController, animated: true, completion: nil)
    }

}
