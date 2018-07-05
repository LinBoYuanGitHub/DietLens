//
//  RulerDialog.swift
//  DietLens
//
//  Created by linby on 2018/7/4.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
protocol rulerDialogDelegate {

    func didSelectItem(index: Int, tag: Int)
}

class RulerDialog: UIViewController {

    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var rulerView: UIView!

    var rulerViewDelegate: RulerViewDelegate?

    override func viewDidLoad() {
        let rlView = RulerView(origin: CGPoint(x: 0, y: 0))
        rlView.rulerViewDelegate = rulerViewDelegate
        rulerView.addSubview(rlView)
    }

}
