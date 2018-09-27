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
    @IBOutlet weak var foodNameCenterY: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setUpCell(foodName: String, imageUrl: String, calorieText: String, unitText: String) {
        foodNameLabel.text = foodName
        calorieLabel.text = calorieText
        unitLabel.text = unitText
        thumbnailImage.image = #imageLiteral(resourceName: "loading_img")
        thumbnailImage.kf.setImage(with: URL(string: imageUrl.replacingOccurrences(of: " ", with: "%20") + "?imageView2/0/w/100"), placeholder: #imageLiteral(resourceName: "loading_img"), options: [], progressBlock: nil) { (_, _, _, _) in}
    }

}
