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
    @IBOutlet weak var activitySlider: UISlider!
    //activity text
    @IBOutlet weak var exerciseLabel: UILabel!
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var activityText: UITextView!
    //profile entity
    var profile: UserProfile?
    var indexValue: Int  = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSliderBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.leftBarButtonItem =  UIBarButtonItem(image: #imageLiteral(resourceName: "Back Arrow"), style: .plain, target: self, action: #selector(onBackPressed))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1.0)
        self.navigationItem.title = "Sign Up"
    }

    @objc func onBackPressed() {
        self.navigationController?.popViewController(animated: true)
    }

    func setUpSliderBar() {
        let clearImage = UIImage().stretchableImage(withLeftCapWidth: 14, topCapHeight: 0)
        activitySlider.setMinimumTrackImage(clearImage, for: .normal)
        activitySlider.setMaximumTrackImage(clearImage, for: .normal)
        //set slider bar tap event
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector((onSliderTapped(_:))))
        activitySlider.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc func onSliderTapped(_ gestureRecognizer: UIGestureRecognizer) {
        let pointTapped: CGPoint = gestureRecognizer.location(in: self.view)
        let positionOfSlider: CGPoint = activitySlider.frame.origin
        let widthOfSlider: CGFloat = activitySlider.frame.size.width
        let newValue = ((pointTapped.x - positionOfSlider.x) * CGFloat(activitySlider.maximumValue-activitySlider.minimumValue) / widthOfSlider)
        indexValue = Int(newValue) + 1  //strat from 1
        if indexValue > 0 && indexValue < 5 {
            activitySlider.setValue(Float(indexValue) + 0.5, animated: true)
            setUpActivtyLevel(indexValue: indexValue)
        }
    }

    @IBAction func onSliderValueChanged(_ sender: UISlider) {
        indexValue = Int(sender.value)
        if indexValue >= 5 {
            indexValue = 4
        } else if indexValue <= 0 {
            indexValue = 1
        }
        activitySlider.setValue(Float(indexValue) + 0.5, animated: true)
        profile?.activityLevel = indexValue
        setUpActivtyLevel(indexValue: indexValue)
    }

    func setUpActivtyLevel(indexValue: Int) {
        exerciseLabel.text = StringConstants.ExerciseLvlText.exerciseLvlArr[indexValue]
        frequencyLabel.text = StringConstants.ExerciseLvlText.exerciseFrequencyArr[indexValue]
        activityText.text = StringConstants.ExerciseLvlText.exerciseDescriptionArr[indexValue]
    }

    @IBAction func next(_ sender: UIButton) {
        //upload Profile
        let preferences = UserDefaults.standard
        let key = "userId"
        let userId = preferences.string(forKey: key)
        //upload APIService
        if profile != nil {
            APIService.instance.updateProfile(userId: userId!, profile: profile!) { (isSuccess) in
                if isSuccess {
                    if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegistrationFinalVC") as? CalorieGoalViewController {
                        self.navigationController?.pushViewController(dest, animated: true)
                    }
                }
            }
        } else {
            //update profile err msg
            AlertMessageHelper.showMessage(targetController: self, title: "", message: "update profile failed")
        }
    }

    @IBAction func skip(_ sender: UIButton) {
        if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegistrationFinalVC") as? CalorieGoalViewController {
            self.navigationController?.pushViewController(dest, animated: true)
        }
    }

    @IBAction func toSignInPage(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}
