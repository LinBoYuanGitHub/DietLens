//
//  SideMenuCell.swift
//  DietLens
//
//  Created by next on 31/10/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit

class SideMenuCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var buttonName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupSideMenuCell(buttonName name: String, iconImage image: UIImage) {
        icon.image = image
        icon.image?.withRenderingMode(.alwaysTemplate)

        buttonName.text = name
    }

    func cellSelected() {
        buttonName.textColor = #colorLiteral(red: 0.938290596, green: 0.4011681676, blue: 0.3992137313, alpha: 1)
        icon.tintColor = UIColor.red
    }

    func cellUnselected() {
        icon.tintColor = #colorLiteral(red: 0.4035005569, green: 0.4078930914, blue: 0.4076195359, alpha: 1)
        buttonName.textColor = #colorLiteral(red: 0.4035005569, green: 0.4078930914, blue: 0.4076195359, alpha: 1)
    }
}
