//
//  NotificationDetailViewController.swift
//  DietLens
//
//  Created by linby on 2018/6/7.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
import Cosmos

class NotificationDetailViewController: UIViewController {

    @IBOutlet weak var messageView: UITextView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var messageContent: UIView!
    @IBOutlet weak var messageContentHeight: NSLayoutConstraint!
    @IBOutlet weak var questionContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var scroller: UIScrollView!
    @IBOutlet weak var promptHeight: NSLayoutConstraint!
    @IBOutlet weak var promptView: UITextView!

    //radio button set
    var buttons = [UIButton]()

    var notificationModel = NotificationModel()

    override func viewDidLoad() {
        messageView.text = notificationModel.content
//        adjustUITextViewHeight(textView: messageView)
        messageContentHeight.constant = messageView.fs_height + CGFloat(110)
        //hide saveBtn when it's None type
        if notificationModel.responseType == NotificationType.NoneType {
            saveBtn.isHidden = true
        }
        configPromptView()
        addResponseToContent()
        hideKeyboardWhenTappedAround()
    }

    func configPromptView() {
        if notificationModel.prompt.isEmpty {
            promptHeight.constant = 0
        } else {
            promptView.text = notificationModel.prompt
            promptView.isScrollEnabled = false
        }
    }

    func adjustUITextViewHeight(textView: UITextView) {
        textView.translatesAutoresizingMaskIntoConstraints = true
        textView.sizeToFit()
        textView.isScrollEnabled = false
    }

    func addResponseToContent() {
        if notificationModel.responseType == NotificationType.TextFieldType {
            generateTextField()
        } else if notificationModel.responseType == NotificationType.Rating4StarType {
            generateRatingView(totalStars: 4)
        } else if notificationModel.responseType == NotificationType.Rating7StarType {
            generateRatingView(totalStars: 7)
        } else if notificationModel.responseType == NotificationType.SingleOptionType {
            generateSingleOptionView()
        } else if notificationModel.responseType == NotificationType.checkBoxType {
            generateCheckBox()
        }
        //scroller height calculation
    }

    func generateRatingView(totalStars: Int) {
        let screenWidth = UIScreen.main.bounds.width
        let ratingView = CosmosView(frame: CGRect(x: 20, y: 8, width: screenWidth, height: 60))
        ratingView.tag = 100
        ratingView.settings.fillMode = .full

        if totalStars == 7 {
            ratingView.settings.starSize = 28
            ratingView.settings.starMargin = 15
        } else {
            ratingView.settings.starSize = 36
            ratingView.settings.starMargin = 48
        }
        ratingView.settings.totalStars = totalStars
        ratingView.settings.emptyImage = #imageLiteral(resourceName: "emptyStarIcon")
        ratingView.settings.filledImage = #imageLiteral(resourceName: "filledStar")
        contentView.addSubview(ratingView)
    }

    func generateSingleOptionView() {
        //create button set
        let screenWidth = UIScreen.main.bounds.width

        for index in 0..<notificationModel.responseOptions.count {
            let childButton = UIButton(frame: CGRect(x: 20, y: 20+60*index, width: Int(screenWidth), height: 20))
            childButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
            childButton.setTitleColor(UIColor.black, for: .normal)
            childButton.setTitle(notificationModel.responseOptions[index], for: .normal)
            childButton.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 24, bottom: 0.0, right: 0.0)
            //image state setting
            childButton.setImage(UIImage(named: "checkboxuntick.png")!, for: .normal)
            childButton.setImage(UIImage(named: "checkboxtick.png")!, for: .selected)
            childButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
            //text color setting
            childButton.setTitleColor(UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1.0), for: .normal)
            childButton.setTitleColor(UIColor(red: 67/255, green: 67/255, blue: 67/255, alpha: 1.0), for: .selected)
            //add underline
            let underLine = UIView(frame: CGRect(x: 16, y: 49+60*index, width: 344, height: 1))
            underLine.backgroundColor = UIColor(red: 227/255, green: 228/255, blue: 229/255, alpha: 1.0)
            contentView.addSubview(childButton)
            contentView.addSubview(underLine)
            buttons.append(childButton)
        }

    }

    func generateCheckBox() {
        let screenWidth = UIScreen.main.bounds.width
        for index in 0..<notificationModel.responseOptions.count {
            let childButton = UIButton(frame: CGRect(x: 20, y: 20+60*index, width: Int(screenWidth), height: 20))
            childButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
            childButton.setTitleColor(UIColor.black, for: .normal)
            childButton.setTitle(notificationModel.responseOptions[index], for: .normal)
            childButton.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 24, bottom: 0.0, right: 0.0)
            //image state setting
            childButton.setImage(UIImage(named: "checkboxuntick.png")!, for: .normal)
            childButton.setImage(UIImage(named: "checkboxtick.png")!, for: .selected)
            childButton.addTarget(self, action: #selector(onCheckBoxSelected), for: .touchUpInside)
            //text color setting
            childButton.setTitleColor(UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1.0), for: .normal)
            childButton.setTitleColor(UIColor(red: 67/255, green: 67/255, blue: 67/255, alpha: 1.0), for: .selected)
            //add underline
            let underLine = UIView(frame: CGRect(x: 16, y: 49+60*index, width: 344, height: 1))
            underLine.backgroundColor = UIColor(red: 227/255, green: 228/255, blue: 229/255, alpha: 1.0)
            contentView.addSubview(childButton)
            contentView.addSubview(underLine)
        }
    }

    @objc func buttonAction(sender: UIButton!) {
        for button in buttons {
            button.isSelected = false
        }
        sender.isSelected = true
    }

    @objc func onCheckBoxSelected(sender: UIButton!) {
        sender.isSelected = !sender.isSelected
    }

    func generateTextField() {
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
//        border.backgroundColor = UIColor(red: 227/255, green: 228/255, blue: 229/255, alpha: 1.0) as! CGColor
        responseTextField.layer.addSublayer(border)
        responseTextField.layer.masksToBounds = true
    }

    @IBAction func onBackPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func onSaveBtnPressed(_ sender: Any) {
        switch notificationModel.responseType {
        case NotificationType.SingleOptionType:
            if let responseTextField = self.view.viewWithTag(100) as? UITextField {
                APIService.instance.answerNotification(notificationId: notificationModel.id, text: responseTextField.text!, value: 1, answer: []) { (isSuccess) in
                    if isSuccess {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        case NotificationType.checkBoxType:
            break
        case NotificationType.TextFieldType:
            if let responseTextField = self.view.viewWithTag(100) as? UITextField {
                APIService.instance.answerNotification(notificationId: notificationModel.id, text: responseTextField.text!, value: 1, answer: []) { (isSuccess) in
                    if isSuccess {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        case NotificationType.Rating4StarType:
            if let ratingView = self.view.viewWithTag(100) as? CosmosView {
                APIService.instance.answerNotification(notificationId: notificationModel.id, text: String(ratingView.rating), value: 4, answer: []) { (isSuccess) in
                    if isSuccess {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        case NotificationType.Rating7StarType:
            if let ratingView = self.view.viewWithTag(100) as? CosmosView {
                APIService.instance.answerNotification(notificationId: notificationModel.id, text: String(ratingView.rating), value: 7, answer: []) { (isSuccess) in
                    if isSuccess {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        default:
            break
        }

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
