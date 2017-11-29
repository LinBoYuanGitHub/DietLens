//
//  GradientView.swift
//  DietLens
//
//  Created by next on 24/10/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit

@IBDesignable
class GradientView: UIView {

    @IBInspectable var topColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0) {
        didSet {
            self.setNeedsLayout()
        }
    }

    @IBInspectable var bottomColor: UIColor = #colorLiteral(red: 0.228789717, green: 0.1472363472, blue: 0.4400225878, alpha: 1) {
        didSet {
            self.setNeedsLayout()
        }
    }

    override func layoutSubviews() {
        let gradLayer = CAGradientLayer()
        gradLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradLayer.endPoint = CGPoint(x: 1.3, y: 1.3)
        gradLayer.frame = self.bounds
        self.layer.insertSublayer(gradLayer, at: 0)
        self.layer.masksToBounds = true
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.setNeedsLayout()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setNeedsLayout()
    }

}
