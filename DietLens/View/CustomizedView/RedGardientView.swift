//
//  backGroundGardientLayer.swift
//  DietLens
//
//  Created by linby on 2018/5/4.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
@IBDesignable
class RedGardientView: UIView {
    @IBInspectable var topColor: UIColor = #colorLiteral(red: 0.9647058824, green: 0.4, blue: 0.2901960784, alpha: 1) {
        didSet {
            self.setNeedsLayout()
        }
    }

    @IBInspectable var bottomColor: UIColor = #colorLiteral(red: 0.9490196078, green: 0.2470588235, blue: 0.3647058824, alpha: 1) {
        didSet {
            self.setNeedsLayout()
        }
    }

    override func layoutSubviews() {
        let gradLayer = CAGradientLayer()
//                gradLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradLayer.colors = [UIColor.white, UIColor.white]
        gradLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradLayer.endPoint = CGPoint(x: 1.3, y: 1.3)
        gradLayer.frame = self.bounds
        self.layer.insertSublayer(gradLayer, at: 0)
        self.layer.masksToBounds = true
    }
}
