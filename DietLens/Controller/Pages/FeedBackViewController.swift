//
//  feedBackViewController.swift
//  DietLens
//
//  Created by linby on 17/01/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class FeedBackViewController: UIViewController {

    @IBOutlet weak var feedBackTextView: UITextView!
    @IBOutlet weak var sendBtn: UIButton!

    override func viewDidLoad() {//sendFeedBack
        feedBackTextView.becomeFirstResponder()
        feedBackTextView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
        feedBackTextView.textColor = UIColor.lightGray
    }

    @IBAction func sendFeedBack(_ sender: Any) {
        if feedBackTextView.text.isEmpty {
            return
        }
        APIService.instance.sendFeedBack(content: feedBackTextView.text) { (flag) in
            if flag {
                let alert = UIAlertController(title: "", message: "Thanks for sending the feedback, we will procceed the feedback soon", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "Default action"), style: .`default`, handler: { _ in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            } else {
                 AlertMessageHelper.showMessage(targetController: self, title: "", message: "send feedback failed due to network busy")
            }
        }
    }

    @IBAction func onBackPressed(_ sender: Any) {
        if feedBackTextView.text.isEmpty {
            dismiss(animated: true, completion: nil)
            return
        }
        let storyboard = UIStoryboard(name: "AddFoodScreen", bundle: nil)
        if let confirmationAlert =  storyboard.instantiateViewController(withIdentifier: "confirmationVC") as? ConfirmationDialog {
            confirmationAlert.delegate = self
            confirmationAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            confirmationAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            confirmationAlert.contentText = "You have unsaved data"
            confirmationAlert.reminderText = "Are you sure you want to leave?"
            present(confirmationAlert, animated: true)
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if feedBackTextView.textColor == UIColor.lightGray {
            feedBackTextView.text = nil
            feedBackTextView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if feedBackTextView.text.isEmpty {
//            feedBackTextView.text = "Input your suggestion here…"
//            feedBackTextView.textColor = UIColor.lightGray
        }
    }

}

extension FeedBackViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}

extension FeedBackViewController: ConfirmationDelegate {

    func onPositiveBtnPressed() {
        //dismiss feedback page
         dismiss(animated: true, completion: nil)
         dismiss(animated: true, completion: nil)
    }

    func onNegativeBtnPressed() {
        //dismiss dialog only
        dismiss(animated: true, completion: nil)
    }

}
