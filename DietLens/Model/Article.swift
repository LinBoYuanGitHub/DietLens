//
//  Article.swift
//  DietLens
//
//  Created by linby on 08/11/2017.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation

struct Article {
    public var id: Int = 0
    public var articleId: String = ""
    public var timestamp: String = ""
    public var source: String = ""
    public var articleTitle: String = ""
    public var articleURL: String = ""
    public var articleContent: String = ""
    public var articleImageURL: String = ""

    init() {

    }

    init(id: Int, title: String, content: String) {
        self.id = id
        self.articleTitle = title
        self.articleContent = content
    }
}
