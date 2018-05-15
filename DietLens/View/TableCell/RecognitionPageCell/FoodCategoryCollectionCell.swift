//
//  CategoryCollectionCell.swift
//  DietLens
//
//  Created by linby on 12/04/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
class FoodCategoryCollectionCell: UICollectionViewCell {

    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setUpCell(categoryName: String, categoryImageURL: String) {
        categoryLabel.text = categoryName
        categoryLabel.lineBreakMode = .byWordWrapping
        categoryImage.image = #imageLiteral(resourceName: "loading_img")
        //start load image
        let imageView = UIImageView()
        if categoryImageURL != "" {
            categoryLabel.textColor = UIColor(red: CGFloat(80/255.0), green: CGFloat(80/255.0), blue: CGFloat(80/255.0), alpha: 1)//#5e5e5e
            imageView.af_setImage(withURL: URL(string: categoryImageURL)!, placeholderImage: #imageLiteral(resourceName: "loading_img"), filter: nil,
                                       imageTransition: .crossDissolve(0.5), completion: { _ in
                                        self.categoryImage.image = imageView.image
            })
        } else {
            categoryLabel.textColor = UIColor.white
            categoryImage.image = #imageLiteral(resourceName: "BestMatchIcon")
        }

    }
}
