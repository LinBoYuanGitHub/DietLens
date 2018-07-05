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

    var activitySelectDelegate: activitySelectDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSliderBar()
    }

    func setUpSliderBar() {
        let clearImage = UIImage().stretchableImage(withLeftCapWidth: 14, topCapHeight: 0)
        activityLvlSlider.setMinimumTrackImage(clearImage, for: .normal)
        activityLvlSlider.setMaximumTrackImage(clearImage, for: .normal)
    }

    @IBAction func onSliderValueChanged(_ sender: UISlider) {
        let indexValue = Int(sender.value)
        activityLVlTextView.text = StringConstants.ExerciseLvlText.exerciseDescriptionArr[indexValue]
    }

    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
        //navigation controller
        self.navigationController?.navigationBar.isHidden = false
        let textColor = UIColor(red: CGFloat(67/255), green: CGFloat(67/255), blue: CGFloat(67/255), alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: textColor, kCTFontAttributeName: UIFont(name: "PingFangSC-Regular", size: 18)!] as! [NSAttributedStringKey: Any]
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }

    @IBAction func save(_ sender: UIBarButtonItem) {
        if activitySelectDelegate != nil {
            activitySelectDelegate?.onActivitySelect(index: Int(activityLvlSlider.value))
        }
    }

}
