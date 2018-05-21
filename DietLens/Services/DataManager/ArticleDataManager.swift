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
    public var eventList = [Article]()
    //pagering for article list
    var articleCurrentPage: Int = 0
    //pagering for event list
    var eventCurrentPage: Int = 0

    private init() {

    }

    func assembleArticles(jsonArr: JSON) -> [Article] {
        articleList.removeAll()
        for i in 0..<jsonArr.count {
            var article = Article()
            article.articleId = jsonArr[i]["id"].stringValue
            article.articleTitle = jsonArr[i]["title"].stringValue
            article.articleContent = jsonArr[i]["content"].stringValue
            article.articleImageURL = jsonArr[i]["image"].stringValue
            article.source = jsonArr[i]["source"].stringValue
            articleList.append(article)
        }
        return articleList
    }

    func assembleEvents(jsonArr: JSON) -> [Article] {
        eventList.removeAll()
        for i in 0..<jsonArr.count {
            var article = Article()
            article.articleId = jsonArr[i]["id"].stringValue
            article.articleTitle = jsonArr[i]["title"].stringValue
            article.articleContent = jsonArr[i]["content"].stringValue
            article.articleImageURL = jsonArr[i]["image"].stringValue
            eventList.append(article)
        }
        return eventList
    }

}
