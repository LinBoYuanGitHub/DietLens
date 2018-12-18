//
//  clinicalStudyTableViewCell.swift
//  DietLens
//
//  Created by 马胖 on 6/12/18.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class ClinicalStudyTableViewCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var studyName: UILabel!
    @IBOutlet weak var studyStartDate: UILabel!

    @IBOutlet weak var containview: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setUpCell(recordType: String, study_Name: String, studyStartOnDate: String) {

        switch recordType {
        case "Food Recommendation":
            studyName.text = study_Name
            icon.image = #imageLiteral(resourceName: "healthCenter_weight")
            studyStartDate.text = studyStartOnDate
            containview.backgroundColor = UIColor(red: 248/255, green: 105/255, blue: 82/255, alpha: 1)

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
