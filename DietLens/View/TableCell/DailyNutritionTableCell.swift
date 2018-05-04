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
    func setUpCell(name: String, value: String, progress: Int, unit: String) {
        nameLabel.text = name
        valueLabel.text = value + unit
        progressView.transform = progressView.transform.scaledBy(x: 1, y: 6)
        progressView.layer.cornerRadius = 20
        progressView.clipsToBounds = true
//        setLayoutLayer()
        UIView.animate(withDuration: 1.0, delay: 0.5, options: .curveEaseIn, animations: {
            self.progressView.progress = Float(progress)/100
            self.progressView.setProgress(Float(progress)/100, animated: true)
            self.progressView.layoutIfNeeded()
        }, completion: nil)
        percentageLabel.text = "\(Int(progress))%"
    }

    func setLayoutLayer() {
        self.progressView.fs_height = 10
        let maskLayerPath = UIBezierPath(roundedRect: bounds, cornerRadius: 4.0)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskLayerPath.cgPath
        self.progressView.layer.mask = maskLayer
    }

}
