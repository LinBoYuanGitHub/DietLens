//
//  HealthCenterMainCell.swift
//  DietLens
//
//  Created by linby on 2018/6/29.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class HealthCenterMainCell: UITableViewCell {
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var conentView: UIView!

    var unit = ""

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setUpCell(recordType: String, latestValue: Float, dateTime: String) {
        if dateTime == " , " {
            dateLabel.text = "----"
        } else {
            dateLabel.text = dateTime
        }
        switch recordType {
        case "0":
            itemName.text = "Weight"
            icon.image = #imageLiteral(resourceName: "healthCenter_weight")
            if latestValue == 0.0 {
                valueLabel.text = "----"
            } else {
                let textStr = String(latestValue) + "KG"
                setAttributeText(textStr: textStr, textLabel: valueLabel, textLength: 2)
            }
            container.backgroundColor = UIColor(red: 248/255, green: 105/255, blue: 82/255, alpha: 1)
        case "1":
            itemName.text = "Blood glucose"
            icon.image = #imageLiteral(resourceName: "healthCenter_bloodGulcose")
            if latestValue == 0.0 {
                valueLabel.text = "----"
            } else {
                let textStr = String(latestValue) + "mmol/L"
                setAttributeText(textStr: textStr, textLabel: valueLabel, textLength: 6)
            }
            container.backgroundColor = UIColor(red: 251/255, green: 137/255, blue: 6/2559, alpha: 1)
        case "2":
            itemName.text = "Mood"
            icon.image = #imageLiteral(resourceName: "healthCenter_mood")
            let index = Int(latestValue)
            valueLabel.text = HealthCenterConstants.moodList[index]
            container.backgroundColor = UIColor(red: 255/255, green: 183/255, blue: 33/255, alpha: 1)
        default:
            break
        }
    }

    func setAttributeText(textStr: String, textLabel: UILabel, textLength: Int) {
        let textAttr = NSMutableAttributedString.init(string: textStr)
        textAttr.setAttributes([ kCTForegroundColorAttributeName as NSAttributedStringKey: UIColor.gray, NSAttributedStringKey.font: UIFont(name: "PingFangSC-Light", size: 14.0) as Any
            ], range: NSRange(location: textStr.count - textLength, length: textLength))
        textLabel.attributedText = textAttr
    }

}
