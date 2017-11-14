//
//  SingleArticleViewController.swift
//  DietLens
//
//  Created by next on 11/11/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit
import ParallaxHeader
import SnapKit
import AlamofireImage

class SingleArticleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var article: UITableView!
    weak var parallaxHeaderView: UIView?

    var test: Article = Article()
    var newsArticle = NewsArticle()
    override func viewDidLoad() {
        super.viewDidLoad()

        article.dataSource = self
        article.delegate = self

        article.parallaxHeader.progress = 0

        test.articleContent = "The question is how to go about it. If you're like most people, you probably think you need to get serious about hitting the gym more often. However, this idea may actually be the fatal flaw that keeps you from succeeding. \n\nThe 2-minute video above, even though it focuses on the fatally flawed theory that weight loss is merely a simple equation of calories in and calories out, still manages to reach the correct conclusion, so it is worth a watch. \n\nWhen it comes to losing weight — and keeping it off — it's crucial to understand that you cannot out-exercise your mouth. Your diet is far more important than exercise,1 although physical movement is the leverage agent that allows you to truly optimize your health and fitness. \n\nExercise has been proven to be as effective (or more) than many drug treatments for common health problems, including diabetes, heart disease and depression, just to name a few. So, exercise definitely plays a role in optimal health — it's just not the central key for weight loss. \n\nYou cannot keep eating a junk food diet and simply exercise your way into smaller pants. Additionally, when and how much you eat can also have a distinct influence. Eating less and paying attention to the timing of your meals can be particularly useful for kick starting your metabolism in the right direction. \n\nResearch Shatters Link Between Exercise and Weight Loss \n\nAccording to Shawn Talbott, Ph.D., a nutritional biochemist and former director of the University of Utah Nutrition Clinic, more than 700 weight loss studies confirm that eating healthier produces greater weight loss results than exercise.2 \n\nOn average, people who dieted without exercising for 15 weeks lost 23 pounds; the exercisers lost only six over about 21 weeks. It's much easier to cut calories than to burn them off. \n\nIndeed, one of the simplest ways to improve your ability to burn fat as your primary fuel and lose weight is to replace all sodas and sweet beverages with pure water. Condiments and snacks are other categories that can be eliminated without risking nutritional deficits, thereby lowering your overall calorie consumption. \n\nMost recently, an international study again confirmed the fact that exercise was largely unrelated to weight loss.3,4,5  Even more surprisingly, sedentary behavior wasn't even strongly associated with weight gain. As noted by Science Daily:6 \n\nPeople who are physically active tend to be healthier and live longer. But while physical activity burns calories, it also increases appetite, and people may compensate by eating more or by being less active the rest of the day  \n\nSurprisingly, total weight gain in every country was greater among participants who met the physical activity guidelines. For example, American men who met the guidelines gained a half pound per year, while American men who did not meet the guideline lost 0.6 pounds. \n\nSimilar findings were made in 2012, when a systematic review7 of studies found that, over time, people who exercised regularly wound up burning less energy than predicted based on their activity levels — a phenomenon known as metabolic compensation. They also increased their overall calorie intake. \n\nMoreover, exercise only accounts for 10 to 30 percent of your overall energy expenditure each day. How many calories you burn in total each day primarily depends on your resting metabolic rate. On the flip side, you have full control over 100 percent of the energy (calories) you put into your body. \n\nThis discrepancy alone is a major clue as to which strategy is likely to have the greatest impact on your weight — exercising more, or reducing excess calorie intake. The video below summarizes the influence physical activity has on your daily calorie expenditure."
        test.id = 324
        test.articleTitle = "So, you need to lose a few pounds"
        test.articleImageURL = "https://httpbin.org/image/jpeg"
        newsArticle = NewsArticle(article: test)

        setupParallaxHeader()
        // Do any additional setup after loading the view.
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "articleMainBody") as? SinglePageArticleBodyCell {
            cell.setupCell(type: .body, data: newsArticle.articleBody)
            return cell
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func setupParallaxHeader() {
        //let image = newsArticle.newsImage

        let imageView = UIImageView()
        //imageView.image = image
        imageView.af_setImage(withURL: URL(string: test.articleImageURL)!, placeholderImage: #imageLiteral(resourceName: "runner"), filter: nil,
                              imageTransition: .crossDissolve(0.5))
        imageView.contentMode = .scaleAspectFill
        parallaxHeaderView = imageView

        imageView.blurView.setup(style: UIBlurEffectStyle.dark, alpha: 1).enable()

        article.parallaxHeader.view = imageView
        article.parallaxHeader.height = 400
        article.parallaxHeader.minimumHeight = 80
        article.parallaxHeader.mode = .centerFill

        let backButton = UIButton()
        backButton.setImage(#imageLiteral(resourceName: "Back Arrow"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        backButton.imageView?.tintColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        imageView.addSubview(backButton)

        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalTo(view.snp.top).offset(38)
        }
        article.parallaxHeader.parallaxHeaderDidScrollHandler = { parallaxHeader in
            //update alpha of blur view on top of image view
            //backButton.snp.updateConstraints({ (make) in
                //make.centerY.equalTo(self.view.snp.top).offset(30)
            //})

            parallaxHeader.view.blurView.alpha = 1 - parallaxHeader.progress
            //backButton.imageView?.alpha = parallaxHeader.progress
        }

        let originalLabel = UILabel()
        originalLabel.text = newsArticle.newsTitle
        originalLabel.numberOfLines = 0
        originalLabel.font = UIFont.systemFont(ofSize: 35.0)
        originalLabel.sizeToFit()
        originalLabel.textAlignment = .left
        originalLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        // Label for vibrant text
        let vibrantLabel = UILabel()
        vibrantLabel.text = newsArticle.newsTitle
        vibrantLabel.numberOfLines = 0
        vibrantLabel.font = UIFont.systemFont(ofSize: 17.0)
        vibrantLabel.sizeToFit()
        vibrantLabel.textAlignment = .left
        vibrantLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        imageView.blurView.blurContentView?.addSubview(vibrantLabel)
        imageView.addSubview(originalLabel)
        //add constraints using SnapKit library
        vibrantLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 5, left: 45, bottom: 5, right: 5))
        }

        originalLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(5)
        }

        imageView.bringSubview(toFront: backButton)
        imageView.isUserInteractionEnabled = true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @objc func backButtonAction(sender: UIButton!) {
//        let btnsendtag: UIButton = sender
//        if btnsendtag.tag == 1 {
//            //do anything here
//        }
        print("click click")
        self.dismiss(animated: true, completion: nil)
    }
}
