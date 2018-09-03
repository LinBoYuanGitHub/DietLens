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
    //tag
    let weightTag = 0
    let heightTag = 1

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
        for button in buttons {
            let redColor = UIColor(red: 244/255, green: 50/255, blue: 84/255, alpha: 1.0)
            button.setTitleColor(redColor, for: .selected)
            button.setTitleColor(UIColor.black, for: .normal)
        }
        //weight ruler
        let weightRuler = RulerView(origin: CGPoint(x: 0, y: 0))
        weightRuler.tag = self.weightTag
        weightRuler.rulerViewDelegate = self
        //height ruler
        let heightRuler = RulerView(origin: CGPoint(x: 0, y: 0))
        heightRuler.tag = self.heightTag
        heightRuler.rulerViewDelegate = self
        //setUp w/h Value
        setAttributeText(textStr: "50kg", textLabel: weightValue)
        setAttributeText(textStr: "165cm", textLabel: heightValue)
        //set current Item
        weightRuler.setCurrentItem(position: 50, animated: false)
        heightRuler.setCurrentItem(position: 165, animated: false)
        //add subView
        weightRulerView.addSubview(weightRuler)
        heightRulerView.addSubview(heightRuler)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.leftBarButtonItem =  UIBarButtonItem(image: #imageLiteral(resourceName: "Back Arrow"), style: .plain, target: self, action: #selector(onBackPressed))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1.0)
        self.navigationItem.title = "Sign Up"
    }

    @objc func onBackPressed() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc func selectGender(sender: UIButton!) {
        for button in buttons {
            button.isSelected = false
        }
        sender.isSelected = true
        sender.titleLabel?.textColor = UIColor.red
    }

    @IBAction func next(_ sender: UIButton) {
        //setUp data
        if male.isSelected {
            profile?.gender = 1
        } else {
            profile?.gender = 0
        }
        //check data
        if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegistrationVC4") as? RegistrationForthStepViewController {
            dest.profile = self.profile
            self.navigationController?.pushViewController(dest, animated: true)
        }
    }

    @IBAction func skip(_ sender: UIButton) {
        if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegistrationVC4") as? RegistrationForthStepViewController {
            dest.profile = self.profile
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

extension RegistrationThirdStepViewController: RulerViewDelegate {

    func didSelectItem(rulerView: RulerView, with index: Int) {
        //return value to ruler
        if rulerView.tag == weightTag {
            let textStr = "\(index)kg"
            setAttributeText(textStr: textStr, textLabel: weightValue)
            profile?.weight = Double(index)
        } else if rulerView.tag == heightTag {
            let textStr = "\(index)cm"
            setAttributeText(textStr: textStr, textLabel: heightValue)
            profile?.height = Double(index)
        }
    }

    func setAttributeText(textStr: String, textLabel: UILabel) {
        let textAttr = NSMutableAttributedString.init(string: textStr)
        textAttr.setAttributes([ kCTForegroundColorAttributeName as NSAttributedStringKey: UIColor.gray, NSAttributedStringKey.font: UIFont(name: "PingFangSC-Light", size: 14.0) as Any
                               ], range: NSRange(location: textStr.count - 2, length: 2))
        textLabel.attributedText = textAttr
    }
}
