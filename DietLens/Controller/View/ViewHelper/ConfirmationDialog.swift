//
//  ConfirmationDialog.swift
//  DietLens
//
//  Created by linby on 2018/9/3.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

protocol ConfirmationDelegate {

    func onPositiveBtnPressed()

    func onNegativeBtnPressed()
}

class ConfirmationDialog: UIViewController {
    @IBOutlet weak var positiveBtn: UIButton!
    @IBOutlet weak var negativeBtn: UIButton!
    @IBOutlet weak var textContent: UITextView!
    @IBOutlet weak var remindLabel: UILabel!

    var delegate: ConfirmationDelegate?

    override func viewWillAppear(_ animated: Bool) {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.63)
    }

    func setUpDialogData(titleText: String, labelText: String) {
        remindLabel.text = titleText
        textContent.text = labelText
    }

    @IBAction func onPositiveBtnPressed(_ sender: UIButton) {
        if delegate != nil {
            delegate?.onPositiveBtnPressed()
        }
    }

    @IBAction func onNegativeBtnPressed(_ sender: UIButton) {
        if delegate != nil {
            delegate?.onNegativeBtnPressed()
        }
    }

}
