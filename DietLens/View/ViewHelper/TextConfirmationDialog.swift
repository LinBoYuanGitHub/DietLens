//
//  TextConfirmationDialog.swift
//  DietLens
//
//  Created by boyuan lin on 10/12/18.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

protocol ConfirmationDialogDelegate {

    func onConfirmBtnPressed()

}

class TextConfirmationDialog: UIViewController {

    @IBOutlet weak var textContent: UILabel!
    @IBOutlet weak var confirmBtn: UIButton!

    var content: String = ""
    var confirmText: String = ""

    var delegate: ConfirmationDialogDelegate?

    override func viewWillAppear(_ animated: Bool) {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.63)
        textContent.text = content
        confirmBtn.titleLabel?.text = confirmText
    }

    @IBAction func onConfirmBtnPressed(_ sender: Any) {
        if delegate != nil {
            delegate?.onConfirmBtnPressed()
        }
    }

}
