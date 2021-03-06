//
//  StepCounterCell.swift
//  DietLens
//
//  Created by linby on 27/12/2017.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit
class StepCounterCell: UITableViewCell {

    @IBOutlet weak var stepDate: UILabel!
    @IBOutlet weak var cellProgressView: UIProgressView!

    @IBOutlet weak var stepValue: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setupCell(stepEntity: StepEntity, maxValue: Double) {
        stepDate.text = "\( DateUtil.day3MDateToString(date: stepEntity.date!)):"
        stepValue.text = "\(String(format: "%.0f", stepEntity.stepValue))"
        //progress bar color & animation setting
        if stepEntity.stepValue > 6000 {
            cellProgressView.progressTintColor = UIColor.init(red: 91/255, green: 189/255, blue: 24/255, alpha: 1.0)
        } else if stepEntity.stepValue > 4000 {
            cellProgressView.progressTintColor = UIColor.init(red: 255/255, green: 183/255, blue: 33/255, alpha: 1.0)
        } else {
            cellProgressView.progressTintColor = UIColor.init(red: 242/255, green: 64/255, blue: 93/255, alpha: 1.0)
        }
        self.cellProgressView.setProgress(0.5, animated: false)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
            UIView.animate(withDuration: 1, delay: 1, options: .curveEaseIn, animations: {
                self.cellProgressView.setProgress(Float(stepEntity.stepValue/maxValue), animated: true)
            }, completion: nil)
        }

    }
}
