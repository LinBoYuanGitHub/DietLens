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
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var eventNewsTitle: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var healthyStack: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func hideTitle() {
        healthyStack.isHidden = true
    }

    func setuUpCell(article: Article) {
        if article.articleImageURL != "" && !article.articleImageURL.isEmpty {
            let imageView = UIImageView()
            imageView.af_setImage(withURL: URL(string: article.articleImageURL)!, placeholderImage: #imageLiteral(resourceName: "loading_img"), filter: nil, imageTransition: .crossDissolve(0.5), completion: { _ in
                self.eventImageView.image = imageView.image
            })
            eventNewsTitle.text = article.articleTitle
//            SourceLabel.text = article.source
            //TODO set the date text
        }
    }

}
