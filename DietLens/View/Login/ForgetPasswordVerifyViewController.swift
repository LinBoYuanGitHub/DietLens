//
//  ForgetPasswordVerifyViewController.swift
//  DietLens
//
//  Created by next on 26/2/18.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class ForgetPasswordVerifyViewController: UIViewController, UITextFieldDelegate {

    var emailFromForgetPw: String = ""
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var verificationField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        verificationField.delegate = self
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailField.text = emailFromForgetPw
        verificationField.becomeFirstResponder()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == verificationField {
            verifyBtnPressed(self)
        }
        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func verifyBtnPressed(_ sender: Any) {
        if let veriCode = verificationField.text, !veriCode.isEmpty {
            // TODO:Check with backend server if verification code is correct
            APIService.instance.resetVerifyRequest(userEmail: emailFromForgetPw, verificationCode: veriCode, completion: { (succeeded) in
                if succeeded {
                    self.performSegue(withIdentifier: "GoToForgetPwMain", sender: self)
                } else {
                    self.alertWithTitle(title: "Error!", message: "Wrong verification code, please check your email again", viewController: self, toFocus: self.verificationField)
                }
            })

        } else {
            alertWithTitle(title: "Error!", message: "Please enter the verification code you have received", viewController: self, toFocus: verificationField)
        }

    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let verificationPage = segue.destination as? ForgetPasswordMainViewController {
            verificationPage.emailToDisplay = emailFromForgetPw
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    func alertWithTitle(title: String!, message: String, viewController: UIViewController, toFocus: UITextField) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: {_ in
            toFocus.becomeFirstResponder()
        })
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }

}
