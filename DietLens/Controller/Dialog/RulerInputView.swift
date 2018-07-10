//
//  RulerInputView.swift
//  DietLens
//
//  Created by linby on 2018/7/5.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

protocol RulerInputDelegate: class {
    func onRulerDidSelectItem(tag: Int, index: Int)
}

class RulerInputView: UIView {

    @IBOutlet weak var rulerViewContainer: UIView!
    @IBOutlet weak var textLabel: UILabel!
    weak var delegate: RulerInputDelegate?
    var rulerView: RulerView!
    var unit = ""
    var rulerTag = 0

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeSubviews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeSubviews()
    }

    func initializeSubviews() {
        let xibFileName = "RulerLayout" // xib extension not included
        if let view =  Bundle.main.loadNibNamed(xibFileName, owner: self, options: nil)?[0] as? UIView {
            rulerView = RulerView(origin: CGPoint(x: 0, y: 0))
            rulerView.rulerViewDelegate = self
            rulerViewContainer.addSubview(rulerView)
            self.addSubview(view)
            view.frame = self.bounds
        }

    }

}

extension RulerInputView: RulerViewDelegate {

    func didSelectItem(rulerView: RulerView, with index: Int) {
        textLabel.text = String(index) + unit
        delegate?.onRulerDidSelectItem(tag: rulerTag, index: index)
    }

}
