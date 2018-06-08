//
//  NotificationTableCell.swift
//  DietLens
//
//  Created by next on 29/11/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit

class NotificationTableCell: UITableViewCell {

    @IBOutlet weak var readIcon: RoundedImage!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var time: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupCell(notificationData: NotificationModel) {
        title.text = notificationData.title
        content.text = notificationData.body
        if notificationData.read {
            readIcon.isHidden = true
//            readIcon.backgroundColor = #colorLiteral(red: 0.6061837673, green: 0.6066573262, blue: 0.6062571406, alpha: 1)
            title.textColor = #colorLiteral(red: 0.6061837673, green: 0.6066573262, blue: 0.6062571406, alpha: 1)
            content.textColor = #colorLiteral(red: 0.6061837673, green: 0.6066573262, blue: 0.6062571406, alpha: 1)
        } else {
             readIcon.isHidden = false
//            readIcon.backgroundColor = #colorLiteral(red: 0.9995045066, green: 0.3144028485, blue: 0.3113412559, alpha: 1)
            title.textColor = #colorLiteral(red: 0.2319577109, green: 0.2320933503, blue: 0.2404021281, alpha: 1)
            content.textColor = #colorLiteral(red: 0.2319577109, green: 0.2320933503, blue: 0.2404021281, alpha: 1)
        }

    }
}
