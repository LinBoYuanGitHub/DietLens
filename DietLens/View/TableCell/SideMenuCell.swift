//
//  SideMenuCell.swift
//  DietLens
//
//  Created by next on 31/10/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit

@IBDesignable
class SideMenuCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var buttonName: UILabel!

    @IBInspectable var leftColor: UIColor = #colorLiteral(red: 0.9725260139, green: 0.9732618928, blue: 0.9726399779, alpha: 0.08448863636) {
        didSet {
            self.setNeedsLayout()
        }
    }

    @IBInspectable var rightColor: UIColor = #colorLiteral(red: 0.9627947661, green: 0.9627947661, blue: 0.9627947661, alpha: 0) {
        didSet {
            self.setNeedsLayout()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView?.backgroundColor = UIColor.clear
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupSideMenuCell(buttonName name: String, iconImage image: UIImage) {
        icon.image = image
        icon.image?.withRenderingMode(.alwaysTemplate)
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        buttonName.text = name
        blurView.alpha = 0
        rightColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        leftColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)

    }

    func cellSelected() {
        //buttonName.textColor = #colorLiteral(red: 0.938290596, green: 0.4011681676, blue: 0.3992137313, alpha: 1)
        //icon.tintColor = UIColor.red
        leftColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.1017471591)
        rightColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
    }

    func cellUnselected() {
        //icon.tintColor = #colorLiteral(red: 0.4035005569, green: 0.4078930914, blue: 0.4076195359, alpha: 1)
        //buttonName.textColor = #colorLiteral(red: 0.4035005569, green: 0.4078930914, blue: 0.4076195359, alpha: 1)
        rightColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        leftColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
    }

    override func layoutSubviews() {
        let gradLayer = CAGradientLayer()
        gradLayer.colors = [leftColor.cgColor, rightColor.cgColor]
        gradLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradLayer.frame = self.bounds

        selectedBackgroundView?.layer.insertSublayer(gradLayer, at: 0)
        selectedBackgroundView?.layer.masksToBounds = true
    }
}
