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
        buttonName.text = name
    }
}
