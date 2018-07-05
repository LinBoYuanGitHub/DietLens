//
//  RulerInputView.swift
//  DietLens
//
//  Created by linby on 2018/7/5.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

protocol RulerDelegate: class {
    func onRulerScaleSelect(index:Int)
}

class RulerInputView: UIView {
    
    weak var delegate:RulerDelegate?
    @IBOutlet var rulerView:UIView!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeSubviews()
        let subView = RulerView(origin: CGPoint(x: 0, y: 0))
        rulerView.addSubview(subView)
    }
    
    func initializeSubviews() {
        let xibFileName = "RulerLayout" // xib extension not included
        let view = Bundle.main.loadNibNamed(xibFileName, owner: self, options: nil)![0] as! UIView
        self.addSubview(view)
        self.addSubview(rulerView)
        view.frame = self.bounds
    }

}
