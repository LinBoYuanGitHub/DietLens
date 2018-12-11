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
    @IBOutlet weak var statusText: UILabel!
    @IBOutlet weak var containview: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func setUpCell(studyStatus: StudyStatus, name: String) {
        studyName.text = name
        icon.image = UIImage(imageLiteralResourceName: "more_clinical studies_icon")
        //change color according to
        switch studyStatus {
        case .pending:
            statusText.text = "pending"
            containview.backgroundColor = UIColor.ThemeColor.dietLensPendingYellow
        case .process:
            statusText.text = "process"
            containview.backgroundColor = UIColor.ThemeColor.dietLensAcceptedGreen
        case .completed:
            statusText.text = "completed"
            containview.backgroundColor = UIColor.ThemeColor.dietLensCompletedRed
        case .expiry:
            statusText.text = "expiry"
            containview.backgroundColor = UIColor.ThemeColor.dietLensCompletedRed
        default: break
        }
//        studyName.text = study_Name
//        self.icon.image = #imageLiteral(resourceName: "healthCenter_weight")
//        studyStartDate.text = studyStartOnDate
//        containview.backgroundColor = UIColor(red: 248/255, green: 105/255, blue: 82/255, alpha: 1)
    }

}
