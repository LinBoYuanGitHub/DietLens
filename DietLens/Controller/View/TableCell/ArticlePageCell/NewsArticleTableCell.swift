//
//  NewsArticleTableCell.swift
//  DietLens
//
//  Created by next on 11/11/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit

class NewsArticleTableCell: UITableViewCell {

    @IBOutlet weak var articleImage: RoundedImage!
//    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleLabel: NoPaddingTextView!
//    @IBOutlet weak var articleDescription: UILabel!

    @IBOutlet weak var articleSourceLabel: UILabel!

    @IBOutlet weak var articleDataLabel: UILabel!

//    @IBOutlet weak var articleDesciption: NoPaddingTextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupCell(imageURL: String, title: String, source: String, dateStr: String) {
        let imageView = UIImageView()
        //self.articleImage.image = #imageLiteral(resourceName: "loading_img") //set placeholder
        if imageURL != "" {
            imageView.kf.setImage(with: URL(string: imageURL)!, placeholder: #imageLiteral(resourceName: "loading_img"), options: [], progressBlock: nil) { (image, _, _, _) in
                 self.articleImage.image = imageView.image
            }
//            imageView.af_setImage(withURL: URL(string: imageURL)!, placeholderImage: #imageLiteral(resourceName: "loading_img"), filter: nil,
//                                  imageTransition: .crossDissolve(0.5), completion: { _ in
//                                    self.articleImage.image = imageView.image
//            })
        } else {
            imageView.image = #imageLiteral(resourceName: "loading_img")
        }
        //      articleImage.imageFromServerURL(urlString: imageURL)
        titleLabel.text = title
        articleSourceLabel.text = source
        articleDataLabel.text = dateStr
//        articleDesciption.text = description
    }
}
