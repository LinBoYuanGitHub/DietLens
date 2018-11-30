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
        categoryLabel.lineBreakMode = .byWordWrapping
        categoryLabel.text = categoryName
        categoryImage.image = #imageLiteral(resourceName: "loading_img")
        //start load image
//        let imageView = UIImageView()
        if categoryImageURL != "" {
            categoryLabel.textColor = UIColor(red: CGFloat(80/255.0), green: CGFloat(80/255.0), blue: CGFloat(80/255.0), alpha: 1)//#5e5e5e
            categoryImage.kf.setImage(with: URL(string: categoryImageURL.replacingOccurrences(of: " ", with: "%20")), placeholder: #imageLiteral(resourceName: "loading_img"), options: [], progressBlock: nil) { (_, _, _, _) in}
        } else {
            categoryLabel.textColor = UIColor.white
            categoryImage.image = #imageLiteral(resourceName: "BestMatchIcon")
        }

//        let attributedString = NSMutableAttributedString(string: categoryName)
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.lineSpacing = 0
//        attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
//        categoryLabel.attributedText = attributedString
    }
}
