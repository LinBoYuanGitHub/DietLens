//
//  foodNameCell.swift
//  DietLens
//
//  Created by linby on 20/01/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
class FoodNameCell: UITableViewCell {
    @IBOutlet weak var sampleImage: UIImageView!
    @IBOutlet weak var foodName: UILabel!
    @IBOutlet weak var foodKcal: UILabel!

    override func awakeFromNib() {
         super.awakeFromNib()
    }

    func setUpCell(sampleImagePath: String, name: String, calorie: String) {
        sampleImage.image = #imageLiteral(resourceName: "loading_img")
        if sampleImagePath != "" {
            let imageView = UIImageView()
            imageView.af_setImage(withURL: URL(string: sampleImagePath)!, placeholderImage: #imageLiteral(resourceName: "loading_img"), filter: nil, imageTransition: .crossDissolve(0.5), completion: { _ in
                    self.sampleImage.image = imageView.image
            })
        } else {
            sampleImage.image = #imageLiteral(resourceName: "food_sample_image")
        }
        foodName.text = name
        foodKcal.text = calorie
    }
}
