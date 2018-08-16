//
//  searchResultLocationCell.swift
//  DietLens
//
//  Created by linby on 2018/8/14.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class SearchResultLocationCell: UITableViewCell {

    @IBOutlet weak var foodSampleImage: UIImageView!
    @IBOutlet weak var foodName: UILabel!
    @IBOutlet weak var foodCalorie: UILabel!
    @IBOutlet weak var locationLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setUpCell(textResultEntity: TextSearchSuggestionEntity) {
        if textResultEntity.useExpImage {
            foodSampleImage.kf.setImage(with: URL(string: textResultEntity.expImagePath)!, placeholder: #imageLiteral(resourceName: "food_sample_image"), options: nil, progressBlock: nil, completionHandler: nil)
        } else {
            foodSampleImage.image = #imageLiteral(resourceName: "dietlens_sample_background")
        }
        foodName.text = textResultEntity.name
        locationLabel.text = textResultEntity.location + " " + textResultEntity.stall
    }
}
