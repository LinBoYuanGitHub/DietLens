//
//  textSearchResultCell.swift
//  DietLens
//
//  Created by linby on 08/04/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {

    @IBOutlet weak var foodSampleImage: UIImageView!
    @IBOutlet weak var foodName: UILabel!
    @IBOutlet weak var foodCalorie: UILabel!
    @IBOutlet weak var foodPortion: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setUpCell(textResultEntity: TextSearchSuggestionEntity) {
        DispatchQueue.main.async {
            if textResultEntity.useExpImage {
                self.foodSampleImage.image = #imageLiteral(resourceName: "loading_img")
                self.foodSampleImage.kf.setImage(with: URL(string: textResultEntity.expImagePath)!, placeholder: #imageLiteral(resourceName: "loading_img"), options: nil, progressBlock: nil, completionHandler: nil)
            } else {
                self.foodSampleImage.image = #imageLiteral(resourceName: "dietlens_sample_background")
            }
            self.foodName.text = textResultEntity.name
            self.foodCalorie.text = String(textResultEntity.calorie)
            self.foodPortion.text = "1 " + textResultEntity.unit + " (" + String(textResultEntity.weight) + "g" + ")"
        }
    }
}
