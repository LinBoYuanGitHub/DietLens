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
    }

    //fill up name,value,percentage
    func setUpCell(name: String, value: String, progress: Int) {
        nameLabel.text = name
        valueLabel.text = value + StringConstants.UIString.calorieUnit
        progressView.transform = progressView.transform.scaledBy(x: 1, y: 9)
        progressView.layer.cornerRadius = 20
        progressView.clipsToBounds = true
        UIView.animate(withDuration: 1.0, delay: 0.5, options: .curveEaseIn, animations: {
            self.progressView.progress = Float(progress)/100
            self.progressView.setProgress(Float(progress)/100, animated: true)
        }, completion: nil)
        percentageLabel.text = "\(Int(progress))%"

    }

}
