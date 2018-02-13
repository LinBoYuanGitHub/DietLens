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
        feedBackTextView.text = "Input your suggestion here…"
        feedBackTextView.textColor = UIColor.lightGray
        feedBackTextView.becomeFirstResponder()
        feedBackTextView.selectedTextRange = feedBackTextView.textRange(from: feedBackTextView.beginningOfDocument, to: feedBackTextView.beginningOfDocument)
        feedBackTextView.delegate = self
    }

    @IBAction func sendFeedBack(_ sender: Any) {
        if feedBackTextView.text.isEmpty {
            return
        }
        let preferences = UserDefaults.standard
        let key = "userId"
        let userId = preferences.string(forKey: key)
        APIService.instance.sendFeedBack(userId: userId!, content: feedBackTextView.text) { (flag) in
            if(flag) {
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
        dismiss(animated: true, completion: nil)
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if feedBackTextView.textColor == UIColor.lightGray {
            feedBackTextView.text = nil
            feedBackTextView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if feedBackTextView.text.isEmpty {
            feedBackTextView.text = "Input your suggestion here…"
            feedBackTextView.textColor = UIColor.lightGray
        }
    }

}

extension FeedBackViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText = textView.text
        let typeCasteToStringFirst = textView.text as NSString?
        let updatedText = typeCasteToStringFirst?.replacingCharacters(in: range, with: text)

        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if (updatedText?.isEmpty)! {
            textView.text = "Input your suggestion here…"
            textView.textColor = UIColor.lightGray

            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            return false
        }
            // Else if the text view's placeholder is showing and the
            // length of the replacement string is greater than 0, clear
            // the text view and set its color to black to prepare for
            // the user's entry

        else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}