//
//  MealTypeCollectionCell.swift
//  DietLens
//
//  Created by linby on 13/04/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class MealTypeCollectionCell: UICollectionViewCell {
    @IBOutlet weak var mealLabel: UILabel!
    @IBOutlet weak var mealBackground: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setUpCell(isHightLight: Bool, mealStr: String) {
        mealLabel.text = mealStr
        if isHightLight {
            mealBackground.isHidden = false
            mealLabel.textColor = UIColor.white
        } else {
            mealBackground.isHidden = true
            mealLabel.textColor = UIColor.gray
        }
    }
}
