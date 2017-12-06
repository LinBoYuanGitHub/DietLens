//
//  HomeViewController.swift
//  DietLens
//
//  Created by next on 24/10/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit
import PBRevealViewController

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ArticleCollectionCellDelegate {

    @IBOutlet weak var sideMenuButton: UIBarButtonItem!
    @IBOutlet weak var newsFeedTable: UITableView!
    @IBOutlet weak var fatsProgressBar: HomeProgressView!
    @IBOutlet weak var proteinProgressBar: HomeProgressView!
    @IBOutlet weak var carbohydrateProgressBar: HomeProgressView!
    public let articleDatamanager = ArticleDataManager.instance
    var whichArticleIndex = 0

    @IBOutlet weak var headerView: UIView!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "newsFeedRow") as? NewsFeedCell {
                cell.setupNewsArticleRow(articles: articleDatamanager.articleList, whichVCisDelegate: self)
                cell.selectionStyle = .none
                return cell
            }
        } else if indexPath.row == 1 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "otherFeedRow") //as? UITableViewCell
            {
                cell.selectionStyle = .none
                return cell
            }
        }

        return UITableViewCell()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        newsFeedTable.dataSource = self
        newsFeedTable.delegate = self
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedStringKey.font: UIFont(name: "SignPainterHouseScript", size: 32)!, NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.6347548905, green: 0.6361853982, blue: 0.6580147525, alpha: 1)]

        sideMenuButton.target = self.revealViewController()
        sideMenuButton.action = #selector(PBRevealViewController.revealLeftView)
        revealViewController()?.leftViewBlurEffectStyle = .light
        newsFeedTable.estimatedRowHeight = 240
        newsFeedTable.rowHeight = UITableViewAutomaticDimension
        self.fatsProgressBar.progress = 0.01
        self.proteinProgressBar.progress = 0.01
        self.carbohydrateProgressBar.progress = 0.01
        // Do any additional setup after loading the view.
        newsFeedTable.tableHeaderView = headerView

    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getDailyAccumulateCPF()
    }

    func getDailyAccumulateCPF() {
        var foodDiaryList = [FoodDiary]()
        let diaryFormatter = DateFormatter()
        diaryFormatter.setLocalizedDateFormatFromTemplate("dd MMM yyyy")
        foodDiaryList = FoodDiaryDBOperation.instance.getFoodDiaryByDate(date: diaryFormatter.string(from: Date()) )!
        var dailyCarb: Float = 0
        var dailyProtein: Float = 0
        var dailyFat: Float = 0
        for foodDiary in foodDiaryList {
            dailyCarb += (foodDiary.carbohydrate as NSString).floatValue //standard 300
            dailyProtein += (foodDiary.protein as NSString).floatValue //standard 100
            dailyFat += (foodDiary.fat as NSString).floatValue //standard 100
        }
        UIView.animate(withDuration: 1.8, delay: 1.2, options: .curveEaseIn, animations: { self.fatsProgressBar.setProgress(dailyFat/100, animated: true) }, completion: nil)
        UIView.animate(withDuration: 1.6, delay: 1.2, options: .curveEaseIn, animations: { self.proteinProgressBar.setProgress(dailyProtein/100, animated: true) }, completion: nil)
        UIView.animate(withDuration: 1.7, delay: 1.2, options: .curveEaseIn, animations: { self.carbohydrateProgressBar.setProgress(dailyCarb/300, animated: true) }, completion: nil)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return CGFloat(240)
        } else if indexPath.row == 1 {
            return CGFloat(320)
        } else {
            return UITableViewAutomaticDimension
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 0)
    }

    @IBAction func presentCamera(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "AddFoodScreen", bundle: nil)
        guard let vc = storyboard.instantiateInitialViewController()
            else { return }
        present(vc, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func didPressArticle(_ indexOfArticleList: Int) {
        whichArticleIndex = indexOfArticleList
        performSegue(withIdentifier: "presentArticlePage", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let article: Article = articleDatamanager.articleList[whichArticleIndex]
        if let dest = segue.destination as? SingleArticleViewController {
            dest.articleData = article
        }
    }
}
