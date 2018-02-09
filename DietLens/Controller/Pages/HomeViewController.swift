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
    var whichArticleIndex = 0

    @IBOutlet weak var fatLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var carboLabel: UILabel!

    @IBOutlet weak var headerView: UIView!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ArticleDataManager.instance.eventList.count+1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "newsFeedRow") as? NewsFeedCell {
                cell.setupNewsArticleRow(articles: ArticleDataManager.instance.articleList, whichVCisDelegate: self)
                cell.selectionStyle = .none
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "otherFeedRow") as? EventCell {
                cell.selectionStyle = .none
                cell.setuUpCell(imagePath: ArticleDataManager.instance.eventList[indexPath.row-1].articleImageURL)
                if indexPath.row != 1 {
                    cell.hideTitle()
                }
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
//        newsFeedTable.estimatedRowHeight = 240
//        newsFeedTable.rowHeight = UITableViewAutomaticDimension
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
        newsFeedTable.reloadData()
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
        UIView.animate(withDuration: 1.8, delay: 1.2, options: .curveEaseIn, animations: {
            if dailyFat > 100 {
                self.fatsProgressBar.setProgress(1, animated: true)
                self.fatLabel.textColor = UIColor.red
            } else {
                 self.fatsProgressBar.setProgress(dailyFat/100, animated: true)
            }
            self.fatLabel.text = "\(Int(dailyFat))g of 100g"
        }, completion: nil)

        UIView.animate(withDuration: 1.6, delay: 1.2, options: .curveEaseIn, animations: {
            if dailyProtein > 100 {
                self.proteinProgressBar.setProgress(1, animated: true)
                self.proteinLabel.textColor = UIColor.red
            } else {
                 self.proteinProgressBar.setProgress(dailyProtein/100, animated: true)
            }
            self.proteinLabel.text = "\(Int(dailyProtein))g of 100g"
        }, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            UIView.animate(withDuration: 1, delay: 1, options: .curveEaseIn, animations: {
                if dailyCarb > 300 {
                    self.carbohydrateProgressBar.setProgress(1, animated: true)
                    self.carboLabel.textColor = UIColor.red
                } else {
                    self.carbohydrateProgressBar.setProgress(dailyCarb/300, animated: true)
                }
                self.carboLabel.text = "\(Int(dailyCarb))g of 300g"
            }, completion: nil)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return CGFloat(240)
        } else if indexPath.row == 1 {
            return CGFloat(320)
        } else {
            return CGFloat(300)
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
        if let dest = segue.destination as? SingleArticleViewController {
             let article: Article = ArticleDataManager.instance.articleList[whichArticleIndex]
            dest.articleData = article
        }
    }
}
