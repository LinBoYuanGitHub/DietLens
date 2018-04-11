//
//  DailyNutritionTableCell.swift
//  DietLens
//
//  Created by linby on 06/04/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class DailyNutritionTableCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!

    override func awakeFromNib() {
        super.awakeFromNib()
        progressView.progress = 0.0
    }

    //fill up name,value,percentage
    func setUpCell(name: String, value: Int, progress: Int) {
        nameLabel.text = name
        valueLabel.text = String(value) + StringConstants.UIString.calorieUnit
        progressView.progress = Float(progress/100)
        percentageLabel.text = "\(Int(progress*100))%"

    }

}
