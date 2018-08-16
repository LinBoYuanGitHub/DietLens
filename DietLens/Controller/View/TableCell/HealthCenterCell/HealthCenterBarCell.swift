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
            self.progressBar.progressTintColor = UIColor(red: 248/255, green: 105/255, blue: 82/255, alpha: 1)
            emojiImageView.isHidden = true
            dateLabel.isHidden = false
            valueLabel.text = String(value) + "kg"
        } else if category == "glucose" {
            self.progressBar.progressTintColor = UIColor(red: 251/255, green: 137/255, blue: 6/2559, alpha: 1)
            emojiImageView.isHidden = true
            dateLabel.isHidden = false
            valueLabel.text = String(value) + "mmol/L"
        } else {//emoji image
            self.progressBar.progressTintColor = UIColor(red: 255/255, green: 183/255, blue: 33/255, alpha: 1)
            emojiImageView.isHidden = false
            valueLabel.isHidden = true
            switch value {
            case 0:
                emojiImageView.image = #imageLiteral(resourceName: "emoji_white_bad")
            case 1:
                emojiImageView.image = #imageLiteral(resourceName: "emoji_white_sad")
            case 2:
                emojiImageView.image = #imageLiteral(resourceName: "emoji_white_ok")
            case 3:
                emojiImageView.image = #imageLiteral(resourceName: "emoji_white_happy")
            case 4:
                emojiImageView.image = #imageLiteral(resourceName: "emoji_white_excellent")
            default:
                break
            }
        }
        setUpProgressBar(value: value, maxValue: maxValue)
    }

    func setUpProgressBar(value: Float, maxValue: Float) {
        self.progressBar.setProgress(1, animated: false)
//        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
//            UIView.animate(withDuration: 1, delay: 1, options: .curveEaseIn, animations: {
//                self.progressBar.setProgress(Float(value/maxValue), animated: true)
//            }, completion: nil)
//        }
    }
}
