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

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setUpCell(textResultEntity: TextSearchSuggestionEntity) {
        foodSampleImage.image = #imageLiteral(resourceName: "food_sample_image")
        foodName.text = textResultEntity.name
        foodCalorie.text = "130.0 kcal"
    }
}
