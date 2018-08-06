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
        for index in 0..<jsonArr["results"].count {
            var article = Article()
            article.articleId = jsonArr["results"][index]["id"].stringValue
            article.articleTitle = jsonArr["results"][index]["title"].stringValue
            article.articleContent = jsonArr["results"][index]["content"].stringValue
            article.articleImageURL = jsonArr["results"][index]["image"].stringValue
            article.source = jsonArr["results"][index]["source"].stringValue
            articleList.append(article)
        }
        return articleList
    }

    func assembleEvents(jsonArr: JSON) -> [Article] {
        eventList.removeAll()
        for i in 0..<jsonArr["results"].count {
            var article = Article()
            article.articleId = jsonArr["results"][i]["id"].stringValue
            article.articleTitle = jsonArr["results"][i]["title"].stringValue
            article.articleContent = jsonArr["results"][i]["content"].stringValue
            article.articleImageURL = jsonArr["results"][i]["image"].stringValue
            eventList.append(article)
        }
        return eventList
    }

}
