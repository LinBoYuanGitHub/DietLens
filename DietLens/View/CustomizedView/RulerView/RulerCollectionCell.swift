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
        line.frame = CGRect(x: (self.frame.width - 1) / 2, y: 0, width: 1, height: 0)
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
            //add index
            textLabel?.removeFromSuperview()
            if index % 5 == 0 {
                //add scale
                textLabel = UILabel()
                textLabel?.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
                textLabel?.text = "\(index)"
                textLabel?.sizeToFit()
//                textLabel?.center.x = line.frame.minX
                textLabel?.frame = CGRect(x: (self.frame.width - 1) / 2, y: line.frame.height, width: 1, height: 20)
                contentView.addSubview(textLabel!)
                line.frame.size.height = CGFloat(70)
            } else {
                line.frame.size.height = CGFloat(40)
            }
            line.frame.origin.y = frame.height - line.frame.height
        }
    }

}
