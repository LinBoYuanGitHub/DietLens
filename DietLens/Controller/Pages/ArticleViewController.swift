//
//  ArticleViewController.swift
//  DietLens
//
//  Created by next on 11/11/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit

class ArticleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var articleTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        articleTable.dataSource = self
        articleTable.delegate = self
        articleTable.estimatedRowHeight = 90
        articleTable.rowHeight = UITableViewAutomaticDimension
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell") as? NewsArticleTableCell {

            return cell
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "presentArticlePage", sender: self)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? SingleArticleViewController {
            dest.newsArticle = NewsArticle(title: "Here's Why More Exercise Makes You Crave a Healthier Diet", image: #imageLiteral(resourceName: "runner"), articleID: "DAVIDNIELD", articleBody: "Regular exercise does more than keep your muscles toned and your heart healthy: it's also likely to give you an appetite for fruits and vegetables that further improve your overall wellbeing, new research has found. The insight comes from a study of more than 6,000 people born between 1980 and 1984, which tracked their eating and exercise habits from the ages of 18-22 and 23-27, and then their eating habits alone from the ages of 27-31 years old. \nThe team from Indiana University in the US link this to a known phenomenon, known as the transfer effect, where learning new skills and improving in one area of your life automatically triggers a desire for improvements in another. In this case, exercise triggers diet, which is why you might see someone start eating more healthily not long after starting a new gym regime - even if diet changes weren't originally part of the plan. \nThe researchers adjusted the figures gathered by the US Department of Labor’s National Longitudinal Survey of Youth 1997 to take into account differences in sex, race, education, income and body-mass index. With other factors eliminated, there was a distinct correlation: the more we exercise, the more fresh produce we eat. Those who regularly got at least an adequate amount of exercise (defined as 30 minutes for five times or more a week) ate the most fruit and vegetables; those who exercised the least also ate the least. As the healthier respondents grew older, they ate even more fruit and veg. \nThere are two main reasons for this, according to the academics behind the study published in the Journal of American College Nutrition. Firstly, exercising regularly and eating well both lead to the same goal of better overall health, so people are able to switch between them easily. Secondly, once someone has made exercise a habit, it no longer needs as much mental effort - that frees up the brain to start scheming about new ways to feel better. On the flip-side, a more intensive workout regime may not leave enough mental energy to focus on a healthy diet as well. \nThe researchers do admit a few limitations in their own work, including some gaps in the data used and a lack of information about various social and environmental factors that have been used in similar research projects - the data used here were not originally intended for this particular study.")
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
