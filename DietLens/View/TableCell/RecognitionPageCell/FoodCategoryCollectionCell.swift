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
        let imageView = UIImageView()
        if categoryImageURL != "" {
            imageView.af_setImage(withURL: URL(string: categoryImageURL)!, placeholderImage: #imageLiteral(resourceName: "loading_img"), filter: nil,
                                       imageTransition: .crossDissolve(0.5), completion: { _ in
                                        self.categoryImage.image = imageView.image
            })
        } else {
            categoryImage.image = #imageLiteral(resourceName: "BestMatchIcon")
        }

    }
}
