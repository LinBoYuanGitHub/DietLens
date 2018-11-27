//
//  RegistrationFavouriteFoodCell.swift
//  DietLens
//
//  Created by boyuan lin on 26/11/18.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class RegistrationFavouriteFoodCell: UICollectionViewCell {
    @IBOutlet weak var favFoodImageView: UIImageView!
    @IBOutlet weak var favFoodTextName: UILabel!
    @IBOutlet weak var isFavIcon: UIImageView!

    func setUpCell(entity: TextSearchSuggestionEntity) {
        if entity.useExpImage {
            favFoodImageView.kf.setImage(with: URL(string: entity.expImagePath)!, placeholder: #imageLiteral(resourceName: "loading_img"), options: [], progressBlock: nil) { (image, _, _, _) in
            }
        } else {
            favFoodImageView.image = #imageLiteral(resourceName: "loading_img")
        }

        favFoodTextName.text = entity.name
    }

    func toggleFavIcon(isFav: Bool) {
        if isFav {
            isFavIcon.image = UIImage(imageLiteralResourceName: "favStar_select")
        } else {
            isFavIcon.image = UIImage(imageLiteralResourceName: "favStar_unselect")
        }
    }
}
