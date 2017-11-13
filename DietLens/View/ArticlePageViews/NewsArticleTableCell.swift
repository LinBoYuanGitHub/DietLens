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
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var articleDescription: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupCell(image: UIImage, title: String, description: String) {
        self.articleImage.image = image
        self.title.text = title
        self.articleDescription.text = description
    }
}
