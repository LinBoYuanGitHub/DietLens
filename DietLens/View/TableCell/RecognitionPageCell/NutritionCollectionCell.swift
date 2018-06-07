//
//  NutritionCollectionCell.swift
//  DietLens
//
//  Created by linby on 18/04/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class NutritionCollectionCell: UICollectionViewCell {
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var nutritionLabel: UILabel!
    @IBOutlet weak var nutritionValueLabel: UILabel!
    @IBOutlet weak var ovalView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    private func setUpOvalView() {
        ovalView.layer.cornerRadius = CGFloat(ovalView.frame.width)/2.0
        ovalView.backgroundColor = UIColor.white
        //set color layer to fill the the oval
    }

    func setUpCell(nutritionName: String, percentage: Int, nutritionValue: Double, unit: String) {
        setUpOvalView()
        percentageLabel.text = String(percentage) + "%"
        nutritionLabel.text = nutritionName
        if nutritionValue == floor(nutritionValue) {
            nutritionValueLabel.text = String(Int(nutritionValue)) + unit
        } else {
            nutritionValueLabel.text = String(format: "%.1f", nutritionValue) + unit
        }

    }

}
