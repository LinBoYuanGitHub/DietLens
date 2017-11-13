//
//  SinglePageArticleBodyCell.swift
//  DietLens
//
//  Created by next on 12/11/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit

class SinglePageArticleBodyCell: UITableViewCell {

    @IBOutlet weak var textView: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupCell(type: ArticleCellType, data: Any) {
        switch type {
        case .body:
            if let content = data as? String {
                textView.text = content
            }
        default:
            print("not supported as of now")
        }
    }
}

public enum ArticleCellType {
    case body
    case subheader
    case picture
}
