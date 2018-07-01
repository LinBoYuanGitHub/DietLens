//
//  RegistrationForthStepViewController.swift
//  DietLens
//
//  Created by linby on 2018/6/28.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class RegistrationForthStepViewController: UIViewController {
    @IBOutlet weak var descriptionTextView: UITextView!
    //buttons
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var signInBtn: UIButton!
    //slider
    @IBOutlet weak var  activitySlider: UISlider!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSliderBar()
    }

    func setUpSliderBar() {
        let clearImage = UIImage().stretchableImage(withLeftCapWidth: 14, topCapHeight: 0)
        activitySlider.setMinimumTrackImage(clearImage, for: .normal)
        activitySlider.setMaximumTrackImage(clearImage, for: .normal)
    }

    @IBAction func next(_ sender: UIButton) {

    }

    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func toSignInPage(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}
