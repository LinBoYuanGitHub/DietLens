//
//  ConfirmDialog.swift
//  DietLens
//
//  Created by linby on 2018/9/15.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

protocol ConfirmBtnDelegate {
    func onConfirmBtnPressed()
}

class ConfirmDialogViewController: UIViewController {

    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var dialogText: UILabel!
    @IBOutlet weak var dialogIcon: UIImageView!

    var delegate: ConfirmBtnDelegate?

    override func viewWillAppear(_ animated: Bool) {
        setupView()
    }

    func setupView() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.63)
    }

    @IBAction func onConfirmBtnPressed(_ sender: Any) {
        if delegate != nil {
            delegate?.onConfirmBtnPressed()
        }
        self.dismiss(animated: true, completion: nil)
    }

    func setDialogText(dialogString: String) {
        dialogText.text = dialogString
    }

    func setConfirmBtnText(btnString: String) {
        confirmBtn.titleLabel?.text = btnString
    }

}
