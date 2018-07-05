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
    //profile entity
    var profile: UserProfile?

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
    }

    @IBAction func next(_ sender: UIButton) {
        //upload Profile
        let preferences = UserDefaults.standard
        let key = "userId"
        let userId = preferences.string(forKey: key)
        //upload APIService
        if profile != nil {
            APIService.instance.updateProfile(userId: userId!, name: profile!.name, gender: profile!.gender, height: profile!.height, weight: profile!.weight, birthday: profile!.birthday) { (isSuccess) in
                if isSuccess {

                } else {

                }
            }
        } else {
            //update profile err msg
            AlertMessageHelper.showMessage(targetController: self, title: "", message: "update profile failed")
        }
    }

    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func skip(_ sender: UIButton) {
        //to main page
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let viewController = storyboard.instantiateViewController(withIdentifier: "sideLGMenuVC")
//        self.present(viewController, animated: true, completion: nil)
    }

    @IBAction func toSignInPage(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}
