//
//  Article.swift
//  DietLens
//
//  Created by linby on 08/11/2017.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation

struct Article{
    public var id: Int = 0
    public var timestamp: String = ""
    public var source: String = ""
    public var article_title: String = ""
    public var article_URL: String = ""
    public var article_content: String = ""
    public var article_image_URL: String = ""
    
    init(){
        
    }
    
    init(id:Int,title: String, content: String) {
        self.id = id
        self.article_title = title
        self.article_content = content
    }
}
