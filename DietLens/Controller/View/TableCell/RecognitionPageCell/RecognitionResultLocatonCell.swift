//
//  RecognitionResultLocatonCell.swift
//  DietLens
//
//  Created by linby on 2018/8/14.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
class RecognitonLocationResultCell: UITableViewCell {
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var calorieLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setUpCell(foodName: String, imageUrl: String, calorieText: String, locationText: String) {
        foodNameLabel.text = foodName
        calorieLabel.text = calorieText
        unitLabel.text = "100g"
        locationLabel.text = locationText
        thumbnailImage.image = #imageLiteral(resourceName: "loading_img")
        thumbnailImage.kf.setImage(with: URL(string: imageUrl), placeholder: #imageLiteral(resourceName: "loading_img"), options: [], progressBlock: nil) { (_, _, _, _) in}
    }

}
