//
//  HealthCenterEmojiCell.swift
//  DietLens
//
//  Created by linby on 2018/7/9.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class HealthCenterEmojiCell: UITableViewCell {

    @IBOutlet weak var emojiImageView: UIImageView!
    @IBOutlet weak var healthCenterLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        healthCenterLabel.text = "Mood"
    }

    func setUpCell(emojiIndex: Int) {
        switch emojiIndex {
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

    func setUpEmoji() {

    }
}
