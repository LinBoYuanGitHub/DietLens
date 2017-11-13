//
//  NewsArticle.swift
//  DietLens
//
//  Created by next on 25/10/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage

struct NewsArticle {
    public var newsImage: UIImage
    public var newsTitle: String
    public var articleID: String
    public var articleBody: String

    init(title: String, image: UIImage, articleID: String, articleBody: String) {
        self.newsImage = image
        self.newsTitle = title
        self.articleID = articleID
        self.articleBody = articleBody
    }

    init() {
        self.newsImage = #imageLiteral(resourceName: "runner")
        self.newsTitle = "What's More Effective for Weight Loss, Eating Right or Exercising?"
        self.articleID = "3HFET"
        self.articleBody = "So, you need to lose a few pounds. The question is how to go about it. If you're like most people, you probaarbly think you need to get serious about hitting the gym more often. However, this idea may actually be the fatal flaw that keeps you from succeeding. \n\nThe 2-minute video above, even though it focuses on the fatally flawed theory that weight loss is merely a simple equation of calories in and calories out, still manages to reach the correct conclusion, so it is worth a watch. \n\nWhen it comes to losing weight — and keeping it off — it's crucial to understand that you cannot out-exercise your mouth. Your diet is far more important than exercise,1 although physical movement is the leverage agent that allows you to truly optimize your health and fitness. \n\nExercise has been proven to be as effective (or more) than many drug treatments for common health problems, including diabetes, heart disease and depression, just to name a few. So, exercise definitely plays a role in optimal health — it's just not the central key for weight loss. \n\nYou cannot keep eating a junk food diet and simply exercise your way into smaller pants. Additionally, when and how much you eat can also have a distinct influence. Eating less and paying attention to the timing of your meals can be particularly useful for kick starting your metabolism in the right direction. \n\nResearch Shatters Link Between Exercise and Weight Loss \n\nAccording to Shawn Talbott, Ph.D., a nutritional biochemist and former director of the University of Utah Nutrition Clinic, more than 700 weight loss studies confirm that eating healthier produces greater weight loss results than exercise.2 \n\nOn average, people who dieted without exercising for 15 weeks lost 23 pounds; the exercisers lost only six over about 21 weeks. It's much easier to cut calories than to burn them off. \n\nIndeed, one of the simplest ways to improve your ability to burn fat as your primary fuel and lose weight is to replace all sodas and sweet beverages with pure water. Condiments and snacks are other categories that can be eliminated without risking nutritional deficits, thereby lowering your overall calorie consumption. \n\nMost recently, an international study again confirmed the fact that exercise was largely unrelated to weight loss.3,4,5  Even more surprisingly, sedentary behavior wasn't even strongly associated with weight gain. As noted by Science Daily:6 \n\nPeople who are physically active tend to be healthier and live longer. But while physical activity burns calories, it also increases appetite, and people may compensate by eating more or by being less active the rest of the day  \n\nSurprisingly, total weight gain in every country was greater among participants who met the physical activity guidelines. For example, American men who met the guidelines gained a half pound per year, while American men who did not meet the guideline lost 0.6 pounds. \n\nSimilar findings were made in 2012, when a systematic review7 of studies found that, over time, people who exercised regularly wound up burning less energy than predicted based on their activity levels — a phenomenon known as metabolic compensation. They also increased their overall calorie intake. \n\nMoreover, exercise only accounts for 10 to 30 percent of your overall energy expenditure each day. How many calories you burn in total each day primarily depends on your resting metabolic rate. On the flip side, you have full control over 100 percent of the energy (calories) you put into your body. \n\nThis discrepancy alone is a major clue as to which strategy is likely to have the greatest impact on your weight — exercising more, or reducing excess calorie intake. The video below summarizes the influence physical activity has on your daily calorie expenditure."
    }

    init(article: Article) {
        self.articleID = String(article.id)
        self.articleBody = article.articleContent
        self.newsTitle = article.articleTitle
        self.newsImage = #imageLiteral(resourceName: "kid")
        //downloadImage(articleImageURL: article.articleImageURL)
        downloadImage(articleImageURL: "https://httpbin.org/image/jpeg")
    }

    mutating func downloadImage(articleImageURL: String) {
        var result = self
        Alamofire.request(articleImageURL).responseImage { response in
            debugPrint(response)

            print(response.request)
            print(response.response)
            debugPrint(response.result)

            if let image = response.result.value {
                //print("image downloaded: \(image)")
                result.newsImage = image
            }
        }
        self = result
    }
}
