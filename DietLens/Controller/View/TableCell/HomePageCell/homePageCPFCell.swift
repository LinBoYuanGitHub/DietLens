//
//  homePageCPFCell.swift
//  DietLens
//
//  Created by linby on 2018/5/7.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class HomePageCPFCell: UICollectionViewCell {

    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var nutritionLabel: UILabel!
    @IBOutlet weak var percentage: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setupCell(nutritionName: String, progressPercentage: Int) {
        nutritionLabel.text = nutritionName
        percentage.text = String(progressPercentage) + "%"
        progressBar.setProgress(Float(progressPercentage)/100, animated: true)
    }
}
