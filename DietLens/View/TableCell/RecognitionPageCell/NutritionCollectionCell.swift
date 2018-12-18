//
//  NutritionCollectionCell.swift
//  DietLens
//
//  Created by linby on 18/04/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
import BAFluidView

class NutritionCollectionCell: UICollectionViewCell {
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var nutritionLabel: UILabel!
    @IBOutlet weak var nutritionValueLabel: UILabel!
    @IBOutlet weak var ovalView: UIView!

    var fluidView: BAFluidView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpOvalView()
        setUpFluidView()
    }

    private func setUpOvalView() {
        ovalView.layer.cornerRadius = CGFloat(ovalView.frame.width)/2.0
        ovalView.backgroundColor = UIColor.white
        //set color layer to fill the the oval
    }

    private func setUpFluidView() {
        fluidView =  BAFluidView(frame: CGRect(x: 0, y: 0, width: ovalView.frame.width, height: ovalView.frame.height), startElevation: 0)
        fluidView.strokeColor = UIColor.white
        fluidView.fillColor = UIColor(red: 255/255, green: 240/255, blue: 240/255, alpha: 0.8)
        fluidView.keepStationary()
        fluidView.maxAmplitude = 6
        fluidView.minAmplitude = 3
        fluidView.fillDuration = 1
        fluidView.layer.cornerRadius = CGFloat(ovalView.frame.width)/2.0
        ovalView.addSubview(fluidView)
    }

    func setUpCell(nutritionName: String, percentage: Int, nutritionValue: Double, unit: String) {
        percentageLabel.text = String(percentage) + "%"
        nutritionLabel.text = nutritionName
        if nutritionValue == floor(nutritionValue) {
            nutritionValueLabel.text = String(Int(nutritionValue)) + unit
        } else {
            nutritionValueLabel.text = String(format: "%.1f", nutritionValue) + unit
        }
        fluidView.fill(to: Float(percentage)/100 as NSNumber)
        fluidView.startAnimation()
    }

}
