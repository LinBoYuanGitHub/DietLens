//
//  RegistrationViewController.swift
//  DietLens
//
//  Created by next on 7/11/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController {

    @IBOutlet weak var TFNickName: UITextField!
    @IBOutlet weak var TFRePassword: UITextField!
    @IBOutlet weak var TFEmail: UITextField!
    @IBOutlet weak var TFPassword: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        //self.navigationController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func signUpButtonPressed(_ sender: Any) {
        if (TFNickName.text?.isEmpty)! {
            print("please fill in nick name")
            return
        } else if (TFEmail.text?.isEmpty)! {
            print("please fill in email")
            return
        } else if (TFPassword.text?.isEmpty)! {
            print("please fill in password")
            return
        } else if TFRePassword.text != TFPassword.text {
            print("confirm password again please")
            return
        } else {
            APIService.instance.register(uuid: "String", nickName: TFNickName.text!, email: TFEmail.text!, password: TFPassword.text!, completion: { (isSucceed) in
                if isSucceed {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "mainSlideMenuVC") as! MainSlideMenuViewController
                    self.present(vc, animated: true, completion: nil)
                } else {
                    print("register failed")
                }
            })
        }
    }

    @IBAction func signInButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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

extension RegistrationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
