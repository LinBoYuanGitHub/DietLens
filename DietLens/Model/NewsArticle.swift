//
//  NewsArticle.swift
//  DietLens
//
//  Created by next on 25/10/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation
import UIKit

struct NewsArticle {
    private(set) public var newsImage: UIImage
    private(set) public var newsTitle: String
    private(set) public var articleID: String
    private(set) public var articleBody: String

    init(title: String, image: UIImage, articleID: String, articleBody: String) {
        self.newsImage = image
        self.newsTitle = title
        self.articleID = articleID
        self.articleBody = articleBody
    }
}
