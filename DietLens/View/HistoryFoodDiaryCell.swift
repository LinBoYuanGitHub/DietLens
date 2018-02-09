//
//  HistoryFoodDiaryCell.swift
//  DietLens
//
//  Created by linby on 24/01/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class HistoryFoodDiaryCell: UITableViewCell {
    @IBOutlet weak var foodDiaryImage: UIImageView!
    @IBOutlet weak var foodName: UILabel!
    @IBOutlet weak var foodCalorie: UILabel!

    let imageCache = NSCache<NSString, AnyObject>()

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setUpCell(imagePath: String, foodNameString: String, foodCal: String) {
        foodDiaryImage.image = #imageLiteral(resourceName: "food_sample_image")
        foodName.text = foodNameString
        foodCalorie.text = "\(foodCal) kcal"
        loadImageFromFile(imageview: foodDiaryImage, imagePath: imagePath)
    }

    func loadImageFromFile(imageview: UIImageView, imagePath: String) {
        var documentsUrl: URL {
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
        let fileName: String = imagePath
        let filePath = documentsUrl.appendingPathComponent(fileName).path
        if FileManager.default.fileExists(atPath: filePath) {
            DispatchQueue.main.async {
                if let cachedImage = self.imageCache.object(forKey: fileName as NSString) as? UIImage {
                    imageview.image = cachedImage
                    return
                } else {
                    imageview.image = UIImage(contentsOfFile: filePath)
                    self.imageCache.setObject(UIImage(contentsOfFile: (filePath as NSString) as String)!, forKey: fileName as NSString)
                }
            }
        }
    }

}
