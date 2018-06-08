//
//  NotificationDetailViewController.swift
//  DietLens
//
//  Created by linby on 2018/6/7.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
class NotificationDetailViewController: UIViewController {

    @IBOutlet weak var messageView: UITextView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!

    var notificationModel = NotificationModel()

    override func viewDidLoad() {
        adjustUITextViewHeight()
        messageView.text = "Have you made a plan for exercising today?\n What is it?"
        addResponseToContent()
        hideKeyboardWhenTappedAround()
    }

    func adjustUITextViewHeight() {
        messageView.translatesAutoresizingMaskIntoConstraints = true
        messageView.sizeToFit()
        messageView.isScrollEnabled = false
    }

    func addResponseToContent() {
        //type 1
        let responseTextField = UITextField(frame: CGRect(x: 20, y: 8, width: 338, height: 60))
        responseTextField.placeholder = "It's placeholder here"
        //address hardcode tag
        responseTextField.tag = 100
        contentView.addSubview(responseTextField)
        //add underline border
        let border = CALayer()
        let width = CGFloat(1.0)
        border.frame = CGRect(x: 0, y: responseTextField.frame.size.height - width, width: responseTextField.frame.size.width, height: responseTextField.frame.size.height)
        border.borderWidth = width
        responseTextField.layer.addSublayer(border)
        responseTextField.layer.masksToBounds = true
    }

    @IBAction func onBackPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func onSaveBtnPressed(_ sender: Any) {
        
    }

}

extension NotificationDetailViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
