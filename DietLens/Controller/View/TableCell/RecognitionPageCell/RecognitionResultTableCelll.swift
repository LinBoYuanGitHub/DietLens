//
//  RecognitionResultTableCelll.swift
//  DietLens
//
//  Created by linby on 12/04/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class RecognitionResultTableCell: UITableViewCell {

    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var calorieLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setUpCell(foodName: String, imageUrl: String, calorieText: String, unitText: String) {
        foodNameLabel.text = foodName
        calorieLabel.text = calorieText
//        unitLabel.text = unitText
         unitLabel.text = "100g"
        thumbnailImage.image = #imageLiteral(resourceName: "loading_img")
        thumbnailImage.kf.setImage(with: URL(string: imageUrl), placeholder: #imageLiteral(resourceName: "loading_img"), options: [], progressBlock: nil) { (_, _, _, _) in
        }
        //start to load image
//        let imageView = UIImageView()
//        if imageUrl != "" {
//            imageView.af_setImage(withURL: URL(string: imageUrl)!, placeholderImage: #imageLiteral(resourceName: "loading_img"), filter: nil,
//                                  imageTransition: .crossDissolve(0.5), completion: { _ in
//                                self.thumbnailImage.image = imageView.image
//            })
//        } else {
//            thumbnailImage.image = #imageLiteral(resourceName: "loading_img")
//        }
    }

}
