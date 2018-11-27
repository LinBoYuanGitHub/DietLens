//
//  MoreCollectionCell.swift
//  DietLens
//
//  Created by linby on 2018/10/17.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class MoreCollectionCell: UICollectionViewCell {

    @IBOutlet weak var moreImageIcon: UIImageView!
    @IBOutlet weak var moreItemText: UILabel!

    func setUpCell(icon: UIImage, text: String) {
        moreImageIcon.image = icon
        moreItemText.text = text
    }

}
