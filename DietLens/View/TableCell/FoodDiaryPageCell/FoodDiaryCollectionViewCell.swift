//
//  FoodDiaryCollectionViewCell.swift
//  DietLens
//
//  Created by linby on 2018/6/22.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
class FoodDiaryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tickIcon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func showEdit() {
        tickIcon.isHidden = false
    }

    func hideEdit() {
        tickIcon.isHidden = true
        //reset all the tick
        tickIcon.image = #imageLiteral(resourceName: "edit_gray_tick_icon")
    }

    func toggleTick() -> Bool {
        if tickIcon.image == #imageLiteral(resourceName: "edit_red_tick_icon") {
            tickIcon.image = #imageLiteral(resourceName: "edit_gray_tick_icon")
            return false
        } else {
            tickIcon.image = #imageLiteral(resourceName: "edit_red_tick_icon")
            return true
        }
    }

    func checkTick() {
        tickIcon.image = #imageLiteral(resourceName: "edit_red_tick_icon")
    }

    func unCheckTick() {
        tickIcon.image = #imageLiteral(resourceName: "edit_gray_tick_icon")
    }

    func setUpCell(foodDiary: FoodDiaryEntity) {
        imageView.image = #imageLiteral(resourceName: "loading_img")
        if foodDiary.imageId.isEmpty {
            imageView.image = #imageLiteral(resourceName: "dietlens_sample_background")
        } else {
            APIService.instance.qiniuImageDownload(imageKey: foodDiary.imageId, width: Dimen.foodCalendarImageWidth, height: Dimen.foodCalendarImageHeight) { (image) in
                self.imageView.image = image
            }
        }
    }

}
