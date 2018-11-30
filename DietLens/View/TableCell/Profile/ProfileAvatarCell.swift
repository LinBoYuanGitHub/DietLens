//
//  ProfileAvatarCell.swift
//  DietLens
//
//  Created by linby on 2018/7/2.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
class ProfileAvatarCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var textComponent: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setUpCell(textTitle: String) {
        textComponent.text = textTitle
    }
}
