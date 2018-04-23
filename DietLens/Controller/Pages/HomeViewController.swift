//
//  HomeViewController.swift
//  DietLens
//
//  Created by next on 24/10/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit
//import PBRevealViewController
import RealmSwift

class HomeViewController: UIViewController, ArticleCollectionCellDelegate {

    @IBOutlet weak var homeTitleBar: UINavigationItem!
    @IBOutlet weak var sideMenuButton: UIBarButtonItem!
    @IBOutlet weak var newsFeedTable: UITableView!
    @IBOutlet weak var fatsProgressBar: HomeProgressView!
    @IBOutlet weak var proteinProgressBar: HomeProgressView!
    @IBOutlet weak var carbohydrateProgressBar: HomeProgressView!
    //index to mark article/event
    var whichArticleIndex = 0
    var whichEventIndex = 0
    //article Type
    var articleType = ArticleType.ARTICLE

    @IBOutlet weak var fatLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var carboLabel: UILabel!

    @IBOutlet weak var headerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        newsFeedTable.dataSource = self
        newsFeedTable.delegate = self
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        //change statusbarcolor
//        self.navigationItem.leftBarButtonItem = sideMenuButton
//        UINavigationBar.appearance().shadowImage = UIImage()
//        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
//        UINavigationBar.appearance().titleTextAttributes = [
//            NSAttributedStringKey.font: UIFont(name: "SignPainterHouseScript", size: 32)!, NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.6347548905, green: 0.6361853982, blue: 0.6580147525, alpha: 1)]
//        sideMenuButton.target = self.openLeftMenu()
//        sideMenuButton.action = #selector(openLeftMenu)
//        revealViewController()?.leftViewBlurEffectStyle = .light
//        newsFeedTable.estimatedRowHeight = 240
//        newsFeedTable.rowHeight = UITableViewAutomaticDimension
        self.fatsProgressBar.progress = 0.0
        self.proteinProgressBar.progress = 0.0
        self.carbohydrateProgressBar.progress = 0.0
        // Do any additional setup after loading the view.
        newsFeedTable.tableHeaderView = headerView
        //set up tableview Height
        newsFeedTable.tableHeaderView?.fs_height = CGFloat(Dimen.NewsFeedTableHeight)

    }

    @IBAction func onDetailClick(_ sender: Any) {
        //segue to nutrition page
        performSegue(withIdentifier: "toDailyNutrtionDetail", sender: nil)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getDailyAccumulateCPF()
        newsFeedTable.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //setUp title
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.topItem?.title = StringConstants.navigatorTitle.dietlensTitle
    }

    // calculate Nutrition Data & put into homePage
    func getDailyAccumulateCPF() {
        var foodDiaryList = [FoodDiaryModel]()
        foodDiaryList = FoodDiaryDBOperation.instance.getFoodDiaryByDate(date: DateUtil.formatGMTDateToString(date: Date()))!
        var dailyCarb: Float = 0
        var dailyProtein: Float = 0
        var dailyFat: Float = 0

        for foodDiary in foodDiaryList {
            //quantity * weight divide 100g to get the multiply ratio
            let ratio = foodDiary.foodInfoList[foodDiary.selectedFoodInfoPos].portionList[foodDiary.selectedPortionPos].weightValue * (foodDiary.quantity/100)
            dailyCarb += (foodDiary.foodInfoList[foodDiary.selectedFoodInfoPos].carbohydrate as NSString).floatValue * Float(ratio)//standard 300
            dailyProtein += (foodDiary.foodInfoList[foodDiary.selectedFoodInfoPos].protein as NSString).floatValue * Float(ratio) //standard 100
            dailyFat += (foodDiary.foodInfoList[foodDiary.selectedFoodInfoPos].fat as NSString).floatValue * Float(ratio) //standard 100
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
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

    @IBAction func presentCamera(_ sender: UIButton) {
        if let dest = UIStoryboard(name: "AddFoodScreen", bundle: nil).instantiateInitialViewController() as? AddFoodViewController {
            if let navigator = self.navigationController {
                //clear controller to Bottom & add foodCalendar Controller
                navigator.pushViewController(dest, animated: true)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func didPressArticle(_ indexOfArticleList: Int) {
//        articleType = ArticleType.ARTICLE
//        whichArticleIndex = indexOfArticleList
//        performSegue(withIdentifier: "presentArticlePage", sender: self)
        self.dismiss(animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? SingleArticleViewController {
            if articleType == ArticleType.ARTICLE {
                dest.articleData = ArticleDataManager.instance.articleList[whichArticleIndex]
            } else {
                dest.articleData = ArticleDataManager.instance.eventList[whichEventIndex]
            }
        }
        if let dest = segue.destination as? ArticleViewController {
            dest.articleType = self.articleType
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return CGFloat(Dimen.NewsArticleCollectionHeight)
        } else if indexPath.row == 1 {
            return CGFloat(Dimen.EventsFirstRowHeight)
        } else {
            return CGFloat(Dimen.EventsRowHeight)
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 0)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ArticleDataManager.instance.eventList.count + 1
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 { //first collectionView disable interaction
            return
        }
        //navigate to article page
        articleType = ArticleType.EVENT
        whichEventIndex = indexPath.row - 1
        performSegue(withIdentifier: "presentArticlePage", sender: self)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "newsFeedRow") as? NewsFeedCell {
                if cell.moreBtn != nil {
                    cell.moreBtn.addTarget(self, action: #selector(performSegueToArticleList), for: .touchUpInside)
                }
                cell.setupNewsArticleRow(articles: ArticleDataManager.instance.articleList, whichVCisDelegate: self)
                cell.selectionStyle = .none
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "otherFeedRow") as? EventCell {
                cell.selectionStyle = .none
                if cell.moreBtn != nil {
                     cell.moreBtn.addTarget(self, action: #selector(performSegueToEventList), for: .touchUpInside)
                }
                cell.setuUpCell(article: ArticleDataManager.instance.eventList[indexPath.row-1])
                if indexPath.row != 1 {
                    cell.hideTitle()
                }
                return cell
            }
        }

        return UITableViewCell()
    }

    @objc func performSegueToArticleList() {
        articleType = ArticleType.ARTICLE
        performSegue(withIdentifier: "showArticleList", sender: self)
    }

    @objc func performSegueToEventList() {
        articleType = ArticleType.EVENT
        performSegue(withIdentifier: "showArticleList", sender: self)
    }

}
