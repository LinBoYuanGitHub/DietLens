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
     //buttons
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var signInBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func next(_ sender: UIButton) {
        //check data
        if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegistrationVC4") as? RegistrationSecondStepViewController {
            self.navigationController?.pushViewController(dest, animated: true)
        }
    }

    @IBAction func skip(_ sender: UIButton) {
        if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegistrationVC4") as? RegistrationSecondStepViewController {
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
