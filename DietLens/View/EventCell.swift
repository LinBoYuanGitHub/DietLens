//
//  EventCell.swift
//  DietLens
//
//  Created by linby on 30/01/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import Foundation
import UIKit
class EventCell: UITableViewCell {
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var eventTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func hideTitle() {
        eventTitle.isHidden = true
    }

    func setuUpCell(imagePath: String) {
        if imagePath != "" && !imagePath.isEmpty {
            let imageView = UIImageView()
            imageView.af_setImage(withURL: URL(string: imagePath)!, placeholderImage: #imageLiteral(resourceName: "loading_img"), filter: nil, imageTransition: .crossDissolve(0.5), completion: { _ in
                self.eventImageView.image = imageView.image
            })
        }
    }

}
