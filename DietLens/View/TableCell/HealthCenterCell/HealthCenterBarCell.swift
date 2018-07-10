//
//  HealthCenterBarCell.swift
//  DietLens
//
//  Created by linby on 2018/7/10.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class HealthCenterBarCell: UITableViewCell {
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var emojiImageView: UIImageView!
    @IBOutlet weak var progressBar: UIProgressView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setUpCell(category: String, value: Float, maxValue: Float, dateStr: String, timeStr: String) {
        dateLabel.text = dateStr + ", " + timeStr
        if category == "weight" {
            emojiImageView.isHidden = true
            dateLabel.isHidden = false
            valueLabel.text = String(value) + "kg"
        } else if category == "glucose" {
            emojiImageView.isHidden = true
            dateLabel.isHidden = false
            valueLabel.text = String(value) + "mmol/L"
        } else {//emoji image
            emojiImageView.isHidden = false
            valueLabel.isHidden = true
            switch value {
            case 0:
                emojiImageView.image = #imageLiteral(resourceName: "healthCenter_badMood")
            case 1:
                emojiImageView.image = #imageLiteral(resourceName: "healthCenter_notSoGoodMood")
            case 2:
                emojiImageView.image = #imageLiteral(resourceName: "healthCenter_okMood")
            case 3:
                emojiImageView.image = #imageLiteral(resourceName: "healthCenter_happyMood")
            case 4:
                emojiImageView.image = #imageLiteral(resourceName: "healthCenter_excellent")
            default:
                break
            }
        }
        setUpProgressBar(value: value, maxValue: maxValue)
    }

    func setUpProgressBar(value: Float, maxValue: Float) {
        self.progressBar.setProgress(0.5, animated: false)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
            UIView.animate(withDuration: 1, delay: 1, options: .curveEaseIn, animations: {
                self.progressBar.setProgress(Float(value/maxValue), animated: true)
            }, completion: nil)
        }
    }
}
