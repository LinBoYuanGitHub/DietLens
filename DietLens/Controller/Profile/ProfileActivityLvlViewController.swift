//
//  ProfileActivityLvlViewController.swift
//  DietLens
//
//  Created by linby on 2018/7/4.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

protocol activitySelectDelegate {

    func onActivitySelect(index: Int)
}

class ProfileActivityLvlViewController: UIViewController {

    @IBOutlet weak var activityLvlSlider: UISlider!
    @IBOutlet weak var activityLVlTextView: UITextView!
    @IBOutlet weak var exerciseFrequencyLabel: UILabel!
    @IBOutlet weak var exerciseTitleLabel: UILabel!

    var activitySelectDelegate: activitySelectDelegate?
    var indexValue: Int  = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSliderBar()
        setUpActivtyLevel(indexValue: indexValue)
    }

    func setUpSliderBar() {
        let clearImage = UIImage().stretchableImage(withLeftCapWidth: 14, topCapHeight: 0)
        activityLvlSlider.setMinimumTrackImage(clearImage, for: .normal)
        activityLvlSlider.setMaximumTrackImage(clearImage, for: .normal)
    }

    @IBAction func onSliderValueChanged(_ sender: UISlider) {
        indexValue = Int(sender.value)
        if indexValue > 3 {
            indexValue = 3
            return
        }
       setUpActivtyLevel(indexValue: indexValue)
    }

    func setUpActivtyLevel(indexValue: Int) {
        activityLvlSlider.setValue(Float(indexValue), animated: true)
        exerciseTitleLabel.text =  StringConstants.ExerciseLvlText.exerciseLvlArr[indexValue]
        exerciseFrequencyLabel.text = StringConstants.ExerciseLvlText.exerciseFrequencyArr[indexValue]
        activityLVlTextView.text =  StringConstants.ExerciseLvlText.exerciseDescriptionArr[indexValue]
    }

    @objc func onBackPressed() {
        self.navigationController?.popViewController(animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
        //navigation controller
        self.navigationController?.navigationBar.isHidden = false
        let textColor = UIColor(red: CGFloat(67/255), green: CGFloat(67/255), blue: CGFloat(67/255), alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: textColor, kCTFontAttributeName: UIFont(name: "PingFangSC-Regular", size: 18)!] as! [NSAttributedStringKey: Any]
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        //back btn
        self.navigationItem.leftBarButtonItem =  UIBarButtonItem(image: #imageLiteral(resourceName: "Back Arrow"), style: .plain, target: self, action: #selector(onBackPressed))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1.0)
    }

    @IBAction func save(_ sender: UIBarButtonItem) {
        if activitySelectDelegate != nil {
            activitySelectDelegate?.onActivitySelect(index: indexValue)
        }
        self.navigationController?.popViewController(animated: true)
    }

}
