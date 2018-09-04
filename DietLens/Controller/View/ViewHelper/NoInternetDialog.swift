//
//  NoInternetDialog.swift
//  DietLens
//
//  Created by linby on 2018/8/30.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class NoInternetDialog: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        setupView()
    }

    func setupView() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.63)
    }

}
