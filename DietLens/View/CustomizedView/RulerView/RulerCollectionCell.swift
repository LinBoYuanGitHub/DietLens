//
//  RulerCollectionCell.swift
//  DietLens
//
//  Created by linby on 2018/7/3.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class RulerCollectionCell: UICollectionViewCell {

    var textLabel: UILabel?

    private lazy var line: CALayer = {
        let line = CALayer()
        line.frame = CGRect(x: (self.frame.width - 1) / 2, y: 0, width: 1, height: self.frame.height)
        let lineColor = UIColor(red: CGFloat(227/255.0), green: CGFloat(228/255.0), blue: CGFloat(229/255.0), alpha: 1.0)
        line.backgroundColor = lineColor.cgColor
        return line
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.addSublayer(line)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var index: Int = 0 {
        didSet {
            textLabel?.removeFromSuperview()
            let goldenRatio: CGFloat = 0.618
            if index % 5 == 0 {
                textLabel = UILabel()
                textLabel?.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
                textLabel?.text = "\(index)"
                textLabel?.sizeToFit()
                textLabel?.center.x = line.frame.minX
                contentView.addSubview(textLabel!)
                line.frame.size.height = (frame.height * goldenRatio)
            } else {
                line.frame.size.height = (frame.height * goldenRatio * goldenRatio)
            }
            line.frame.origin.y = frame.height - line.frame.height
        }
    }

}
