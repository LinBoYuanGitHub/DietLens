//
//  ConfirmDialogController.swift
//  DietLens
//
//  Created by linby on 2018/8/30.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

protocol ConfirmAlertDialogDelegate: class {
    func onConfirmBtnClicked()
}

class ConfirmDialogController: UIViewController {
    @IBOutlet weak var textContentView: UITextView!
    @IBOutlet weak var confirmBtn: UIButton!

    weak var delegate: ConfirmAlertDialogDelegate?
    var textContent: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        textContentView.text = textContent
    }

    override func viewWillAppear(_ animated: Bool) {
        setupView()
    }

    func setupView() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.63)
    }

    @IBAction func confirm() {
        delegate?.onConfirmBtnClicked()
    }

}
