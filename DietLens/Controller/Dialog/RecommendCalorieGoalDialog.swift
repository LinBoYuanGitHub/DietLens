//
//  RecommendCalorieGoalDialog.swift
//  DietLens
//
//  Created by boyuan lin on 3/12/18.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class RecommendCalorieGoalDialog: UIViewController {
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var recommendText: UITextView!

    override func viewWillAppear(_ animated: Bool) {
        setupView()
    }

    func setupView() {
        recommendText.isEditable = false
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.63)
        getRecommendValue()
    }

    @IBAction func onConfirmBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    func getRecommendValue() {
        APIService.instance.getDietaryGuideInfo { (dietDict) in
            if let calorie = dietDict["energy"] {
                self.recommendText.text = "Your recommended calorie goal is \(Int(calorie)) kcal"
            }
        }
    }
}
