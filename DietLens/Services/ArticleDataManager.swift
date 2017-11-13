//
//  ArticleDataManager.swift
//  DietLens
//
//  Created by linby on 08/11/2017.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation
import SwiftyJSON
class ArticleDataManager {
    static var instance = ArticleDataManager()
    public var articleList = [Article]()
    var page: Int = 0

    private init() {

    }

    func assembleArticles(jsonArr: JSON) -> [Article] {
        for i in 0..<jsonArr.count {
            var article = Article()
            article.id = jsonArr[i]["id"].intValue
            article.articleTitle = jsonArr[i]["article_title"].stringValue
            article.articleContent = jsonArr[i]["article_content"].stringValue
            article.articleImageURL = jsonArr[i]["article_image_URL"].stringValue
            articleList.append(article)
        }
        return articleList
    }

}
