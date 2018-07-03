//
//  RegistrationThridStepViewController.swift
//  DietLens
//
//  Created by linby on 2018/6/28.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class RegistrationThirdStepViewController: UIViewController {
    //ruler view
    @IBOutlet weak var weightRulerView: UIView!
    @IBOutlet weak var heightRulerView: UIView!
    @IBOutlet weak var weightValue: UILabel!
    @IBOutlet weak var heightValue: UILabel!
    //optionButton
    @IBOutlet weak var male: UIButton!
    @IBOutlet weak var female: UIButton!
    var buttons = [UIButton]()
     //buttons
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var signInBtn: UIButton!
    //profile entity
    var profile: UserProfile?

    override func viewDidLoad() {
        super.viewDidLoad()
        //male
        male.setImage(UIImage(named: "option_unselected.png")!, for: .normal)
        male.setImage(UIImage(named: "option_selected.png")!, for: .selected)
        male.addTarget(self, action: #selector(selectGender), for: .touchUpInside)
        //female
        female.setImage(UIImage(named: "option_unselected.png")!, for: .normal)
        female.setImage(UIImage(named: "option_selected.png")!, for: .selected)
        female.addTarget(self, action: #selector(selectGender), for: .touchUpInside)
        //button group
        buttons.append(male)
        buttons.append(female)
        //set up rulerView
        let rulerView = RulerView(origin: CGPoint(x: 0, y: 0))
        weightRulerView.addSubview(rulerView)
    }

    @objc func selectGender(sender: UIButton!) {
        for button in buttons {
            button.isSelected = false
        }
        sender.isSelected = true
    }

    @IBAction func next(_ sender: UIButton) {
        //setUp data
        if male.isSelected {
            profile?.gender = 1
        } else {
            profile?.gender = 0
        }
        profile?.height = 1.80
        profile?.weight = 60.0
        //check data
        if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegistrationVC4") as? RegistrationForthStepViewController {
            dest.profile = self.profile
            self.navigationController?.pushViewController(dest, animated: true)
        }
    }

    @IBAction func skip(_ sender: UIButton) {
        if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegistrationVC4") as? RegistrationForthStepViewController {
            self.navigationController?.pushViewController(dest, animated: true)
        }
    }

    func back() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func toSignInPage(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
