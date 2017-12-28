//
//  MainViewController.swift
//  DietLens
//
//  Created by next on 23/10/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var TFEmail: UITextField!
    @IBOutlet weak var TFPassword: UITextField!

    @IBAction func unwindToMainPage(segue: UIStoryboardSegue) {}

    @IBAction func onLoginBtnClicked(_ sender: Any) {
        if (TFEmail.text?.isEmpty)! {
            AlertMessageHelper.showMessage(targetController: self, title: "", message: "please fill in email")
            return
        } else if (TFPassword.text?.isEmpty)! {
             AlertMessageHelper.showMessage(targetController: self, title: "", message: "please fill in password")
            return
        }
        APIService.instance.loginRequest(userEmail: TFEmail.text!, password: TFPassword.text!) { (isSuccess) in
            if isSuccess {
                self.performSegue(withIdentifier: "loginToMainPage", sender: nil)
            } else {
                AlertMessageHelper.showMessage(targetController: self, title: "", message: "Login failed")
                print("Login failed")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        TFEmail.delegate = self
        TFPassword.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MainViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
