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
    @IBOutlet weak var articleDesciption: NoPaddingTextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupCell(imageURL: String, title: String, description: String) {
        articleImage.imageFromServerURL(urlString: imageURL)
        titleLabel.text = title
        articleDesciption.text = description
    }
}
