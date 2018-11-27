//
//  FoodDiaryRecordViewCell.swift
//  DietLens
//
//  Created by linby on 23/04/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class FoodDiaryRecordViewCell: UITableViewCell {
    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var calorieView: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setUpCell(imageId: String, calorieText: String) {
        calorieView.text = calorieText
        self.foodImageView.image = #imageLiteral(resourceName: "loading_img")
        if imageId.isEmpty {
            self.foodImageView.image = #imageLiteral(resourceName: "dietlens_sample_background")
        } else {
            APIService.instance.qiniuImageDownload(imageKey: imageId, width: Dimen.foodCalendarImageWidth, height: Dimen.foodCalendarImageHeight) { (image) in
                self.foodImageView.image = image
            }
        }

    }

}
