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
    var divisor: Int = 1 //set default divisor as 1
    var min: Int = 0

    private lazy var line: CALayer = {
        let line = CALayer()
        line.frame = CGRect(x: (self.frame.width - 1) / 2, y: 0, width: 1, height: 0)
        let lineColor = UIColor(red: CGFloat(227/255.0), green: CGFloat(228/255.0), blue: CGFloat(229/255.0), alpha: 1.0)
        line.backgroundColor = lineColor.cgColor
        return line
    }()

    private lazy var scaleLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.frame = CGRect(x: (self.frame.width - 1) / 2, y: 50, width: 40, height: 20)
        textLabel.textAlignment = .center
        textLabel.font =  UIFont.systemFont(ofSize: 14)
        let textColor = UIColor(red: CGFloat(227/255.0), green: CGFloat(228/255.0), blue: CGFloat(229/255.0), alpha: 1.0)
        textLabel.textColor = textColor
        return textLabel
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.addSublayer(line)
        contentView.addSubview(scaleLabel)
    }

    init(frame: CGRect, divisor: Int) {
        super.init(frame: frame)
        contentView.layer.addSublayer(line)
        contentView.addSubview(scaleLabel)
        self.divisor = divisor
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    var index: Int = 0 {
//        didSet {
//            //add index
//            textLabel?.removeFromSuperview()
//            if index % 5 == 0 {
//                //add scale
//                textLabel = UILabel()
//                textLabel?.font =  UIFont.systemFont(ofSize: 14)
//                textLabel?.text = "\(index/divisor)"
//                textLabel?.sizeToFit()
//                textLabel?.center.x = line.frame.minX
//                textLabel?.frame = CGRect(x: (self.frame.width - 1) / 2, y: 50, width: 20, height: 20)
//                contentView.addSubview(textLabel!)
//                line.frame.size.height = CGFloat(50)
//            } else {
//                line.frame.size.height = CGFloat(30)
//            }
//        }
//    }

    var index: Int = 0 {
        didSet {
            //add index
            scaleLabel.removeFromSuperview()
            if index % 5 == 0 {
                //add scale
                if divisor == 1 {
                    scaleLabel.text = "\((index)/divisor + min)"
                } else {
                    scaleLabel.text = "\(Double(index)/Double(divisor) + Double(min))"
                }
                scaleLabel.center.x = line.frame.origin.x
                self.contentView.addSubview(scaleLabel)
                line.frame.size.height = CGFloat(50)
            } else {
                line.frame.size.height = CGFloat(30)
            }
        }
    }
}
