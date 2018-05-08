//
//  HomeViewController.swift
//  DietLens
//
//  Created by next on 24/10/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit
import RealmSwift

class HomeViewController: UIViewController, ArticleCollectionCellDelegate {

    @IBOutlet weak var homeTitleBar: UINavigationItem!
    @IBOutlet weak var sideMenuButton: UIBarButtonItem!
    @IBOutlet weak var newsFeedTable: UITableView!
    @IBOutlet weak var cpfCollectionView: UICollectionView!
    @IBOutlet weak var calorieDisplayContainer: UIView!
    @IBOutlet weak var cpfContainer: UIView!

    @IBOutlet weak var totalCalorie: UILabel!
    @IBOutlet weak var intakenCalorie: UILabel!
    @IBOutlet weak var remainCalorie: UILabel!
    @IBOutlet weak var percentageCalorie: UILabel!

    //index to mark article/event
    var whichArticleIndex = 0
    var whichEventIndex = 0
    //article Type
    var articleType = ArticleType.ARTICLE
    //parallax header
//    weak var parallaxHeaderView: UIView?
    @IBOutlet weak var headerView: UIView!

    var displayDict = [Int: (String, Double)]()
    var targetDict = [Int: (String, Double)]()

    override func viewDidLoad() {
        super.viewDidLoad()
        newsFeedTable.dataSource = self
        newsFeedTable.delegate = self
        cpfCollectionView.delegate = self
        cpfCollectionView.dataSource = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        //change statusbarcolor
        newsFeedTable.tableHeaderView = headerView
        loadArticle()
    }

    //assemble the article & event list and display
    func loadArticle() {
        if ArticleDataManager.instance.articleList.count == 0 || ArticleDataManager.instance.eventList.count == 0 {
            APIService.instance.getArticleList(completion: { (_) in
                self.newsFeedTable.reloadData()
            })
            APIService.instance.getEventList(completion: { (_) in
                self.newsFeedTable.reloadData()
            })
        }
    }

    func loadCalorieData(todayIntakenCal: Int) {
        let preferences = UserDefaults.standard
        let totalCal = Int(preferences.double(forKey: PreferenceKey.calorieTarget))
        if totalCal != 0 {
            totalCalorie.text = String(totalCal)
            intakenCalorie.text = String(todayIntakenCal)
            remainCalorie.text = String(totalCal-todayIntakenCal)
            percentageCalorie.text = String(todayIntakenCal*100/totalCal) + "%"
        }
    }

    func requestNutritionDict(requestDate: Date) {
        APIService.instance.getDailySum(date: requestDate) { (resultDict) in
            if resultDict.count == 0 {
                return
            }
            self.assembleDisplayDict(nutritionDict: resultDict)
            self.assembleTargetDict()
            self.cpfCollectionView.reloadData()
            self.loadCalorieData(todayIntakenCal: Int(resultDict["energy"]!))
        }
    }

    func assembleDisplayDict(nutritionDict: Dictionary<String, Double>) {
        displayDict[0] = ("Calorie", nutritionDict["energy"]!)
        displayDict[1] = ("Protein", nutritionDict["protein"]!)
        displayDict[2] = ("Fat", nutritionDict["fat"]!)
        displayDict[3] = ("Carbohydrate", nutritionDict["carbohydrate"]!)
    }

    func assembleTargetDict() {
        let preferences = UserDefaults.standard
        targetDict[0] =  (StringConstants.UIString.calorieUnit, preferences.double(forKey: PreferenceKey.calorieTarget))
        targetDict[1] =  (StringConstants.UIString.diaryIngredientUnit, preferences.double(forKey: PreferenceKey.proteinTarget))
        targetDict[2] =  (StringConstants.UIString.diaryIngredientUnit, preferences.double(forKey: PreferenceKey.fatTarget))
        targetDict[3] =  (StringConstants.UIString.diaryIngredientUnit, preferences.double(forKey: PreferenceKey.carbohydrateTarget))
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
        self.navigationController?.navigationBar.topItem?.title = StringConstants.NavigatorTitle.dietlensTitle
        //SignPainterHouseScript 28.0
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.backgroundColor = UIColor.red
        self.navigationController?.navigationBar.barTintColor = UIColor(red: CGFloat(240.0/255.0), green: CGFloat(90.0/255.0), blue: CGFloat(90.0/255.0), alpha: 1.0)
        self.sideMenuController?.isLeftViewSwipeGestureEnabled = true
        //refresh nutrition part each time view apppear
        requestNutritionDict(requestDate: Date())
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
        articleType = ArticleType.ARTICLE
        whichArticleIndex = indexOfArticleList
        performSegue(withIdentifier: "presentArticlePage", sender: self)
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
                cell.refreshCollectionView()
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

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == newsFeedTable {
            let contentOffset = scrollView.contentOffset.y
//            if contentOffset > 0 {
//                cpfContainer.isHidden = true
//            } else {
//                cpfContainer.isHidden = false
//            }
        }
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

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //CPF total 3 item
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cpfCollectionCell", for: indexPath) as? homePageCPFCell {
            let kvSet = displayDict[indexPath.row+1]
            let targetSet = targetDict[indexPath.row+1]
            var name = ""
            if indexPath.row == 0 {
                name = "PROTEIN"
            } else if indexPath.row == 1 {
                name = "FAT"
            } else {
                name = "CARB"
            }
            var progress = 0
            if kvSet != nil || targetSet != nil {
                if targetSet!.1 == 0 {
                    progress = 0
                } else {
                    progress = Int(kvSet!.1/targetSet!.1*100)
                }
            }
            cell.setupCell(nutritionName: name, progressPercentage: progress)
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CGFloat(110), height: CGFloat(60))
    }

}
