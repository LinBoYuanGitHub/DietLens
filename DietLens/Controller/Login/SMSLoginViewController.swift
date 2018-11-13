//
//  SMSLoginViewController.swift
//  DietLens
//
//  Created by linby on 2018/10/26.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import XLPagerTabStrip

class SMSLoginViewController: UIViewController {

    @IBOutlet weak var mobileNumTextField: UITextField!
    @IBOutlet weak var smsCodeVerifiedTextField: UITextField!
    @IBOutlet weak var areaPhoneCode: UITextField!

    @IBOutlet weak var verifiedCodeSendingBtn: UIButton!
    private var phoneNum = ""

    override func viewDidLoad() {
        mobileNumTextField.keyboardType = .numberPad
        smsCodeVerifiedTextField.keyboardType = .numberPad
        mobileNumTextField.clearButtonMode = .whileEditing
        CountDownTimer.instance.delegate = self
        areaPhoneCode.isUserInteractionEnabled = false
        verifiedCodeSendingBtn.isEnabled = false
        mobileNumTextField.addTarget(self, action: #selector(onTextChanged), for: .editingChanged)
        verifiedCodeSendingBtn.setBackgroundImage(UIImage(imageLiteralResourceName: "verification_gray_button"), for: .disabled)
        verifiedCodeSendingBtn.setTitle("Send", for: .disabled)
        verifiedCodeSendingBtn.setTitleColor(UIColor(displayP3Red: 223.0/255.0, green: 223.0/255.0, blue: 223.0/255.0, alpha: 1), for: .disabled)
        verifiedCodeSendingBtn.setTitleColor(UIColor(displayP3Red: 213.0/255.0, green: 42.0/255.0, blue: 36.0/255.0, alpha: 1), for: .normal)
    }

    @objc func onTextChanged() {
        if CountDownTimer.instance.getCoolDownFlag() {
            if mobileNumTextField.text?.count == 8 {
                verifiedCodeSendingBtn.isEnabled = true
            } else {
                verifiedCodeSendingBtn.isEnabled = false
            }
        }
    }

    @IBAction func sendSMSCode(_ sender: Any) {
        phoneNum = mobileNumTextField.text!
        //SMS sending prerequisite
        if phoneNum.count != 8 { //singapore num count
            AlertMessageHelper.showMessage(targetController: self, title: "", message: "Please enter a valid phone number")
            return
        }
        verifiedCodeSendingBtn.isEnabled = false
        mobileNumTextField.isEnabled = false
        mobileNumTextField.textColor = .gray
        APIService.instance.sendSMSRequest(phoneNumber: "+65"+phoneNum) { (isSuccess) in
            //start count
            if isSuccess {
                CountDownTimer.instance.start()
            } else {
                self.verifiedCodeSendingBtn.isEnabled = true
                self.mobileNumTextField.isEnabled = true
                self.mobileNumTextField.textColor = UIColor(displayP3Red: 67.0/255.0, green: 67.0/255.0, blue: 67.0/255.0, alpha: 1)
            }
        }
    }

    @IBAction func onLoginBtnClicked(_ sender: Any) {
        verifiedSMSCode()
    }

    func verifiedSMSCode() {
        //local prerequisite
        let smsCode = smsCodeVerifiedTextField.text!
        if smsCode.count != 6 { //verfication
            AlertMessageHelper.showMessage(targetController: self, title: "", message: "Verification code is 6-digits")
            return
        }
//        else if phoneNum.count == 0 { //singapore num count
//            AlertMessageHelper.showMessage(targetController: self, title: "", message: "Please send verification code first")
//            return
//        }
        //sms login verify request
        APIService.instance.verifySMSRequest(phoneNumber: "+65"+phoneNum, smsToken: smsCodeVerifiedTextField.text!, completion: { (isSuccess) in
            if isSuccess {
                // save for basic authentication
                let preferences = UserDefaults.standard
                //upload the device token to server
                let fcmToken = preferences.string(forKey: PreferenceKey.fcmTokenKey)
                let userId = preferences.string(forKey: PreferenceKey.userIdkey)
                if userId != nil && fcmToken != nil {
                    APIService.instance.saveDeviceToken(uuid: userId!, fcmToken: fcmToken!, status: true, completion: { (flag) in
                        if flag {
                            print("send device token succeed")
                        }
                    })
                }
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let controller = storyboard.instantiateViewController(withIdentifier: "HomeTabNVC")
                        as? UINavigationController {
                        //                            self.navigationController?.pushViewController(controller, animated: true)
                        self.present(controller, animated: true, completion: nil)
                    }
                }
            } else {
                AlertMessageHelper.showMessage(targetController: self, title: "", message: StringConstants.ErrMsg.loginErrMsg)
                print("Login failed")
            }
        }) { (errorMessage) in
             AlertMessageHelper.showMessage(targetController: self, title: "", message: errorMessage)
        }
    }

}

extension SMSLoginViewController: CountDownDelegate {

    func onCountDownUpdate(displaySeconds: TimeInterval) {
        if displaySeconds <= 0 {
            verifiedCodeSendingBtn.setTitle("Send", for: .normal)
            verifiedCodeSendingBtn.setTitle("Send", for: .disabled)
            verifiedCodeSendingBtn.isEnabled = true
            mobileNumTextField.isEnabled = true
            mobileNumTextField.textColor = UIColor(displayP3Red: 67.0/255.0, green: 67.0/255.0, blue: 67.0/255.0, alpha: 1)
        } else {
            UIView.performWithoutAnimation {
                verifiedCodeSendingBtn.setTitle(String(Int(displaySeconds)) + "s", for: .disabled)
                verifiedCodeSendingBtn.layoutIfNeeded()
            }
        }

    }
}

extension SMSLoginViewController {

    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension SMSLoginViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "SMS")
    }
}
