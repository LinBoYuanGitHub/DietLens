//
//  HomeProgressView.swift
//  DietLens
//
//  Created by next on 26/10/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit

@IBDesignable
class HomeProgressView: UIProgressView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBInspectable var cornerRadius: Double = 2.0
    {
        didSet
        {
            self.setNeedsLayout()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        subviews.forEach { (subview) in
            subview.layer.masksToBounds = true
            subview.layer.cornerRadius = CGFloat(cornerRadius)
        }
    }
}
