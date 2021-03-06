//
//  HomeViewController.swift
//  DietLens
//
//  Created by next on 24/10/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit
import BAFluidView
import Photos
import FirebaseAnalytics

class HomeViewController: BaseViewController, ArticleCollectionCellDelegate {

    @IBOutlet weak var homeTitleBar: UINavigationItem!
    @IBOutlet weak var sideMenuButton: UIBarButtonItem!
    @IBOutlet weak var newsFeedTable: UITableView!
    @IBOutlet weak var cpfCollectionView: UICollectionView!
    @IBOutlet weak var calorieDisplayContainer: UIView!
    @IBOutlet weak var cpfContainer: UIView!
    @IBOutlet weak var homePlusButton: UIButton!

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
    @IBOutlet weak var calorieContainer: UIView!
    var calorieFluidView: BAFluidView!

    var displayDict = [Int: (String, Double)]()
    var targetDict = [Int: (String, Double)]()

    var shouldRefreshMainPageNutrition = true

    override func viewDidLoad() {
        super.viewDidLoad()
        //delegate for new table view
        newsFeedTable.dataSource = self
        newsFeedTable.delegate = self
        cpfCollectionView.delegate = self
        cpfCollectionView.dataSource = self
        //change statusbarcolor
        newsFeedTable.tableHeaderView = headerView
        loadArticle()
        //for sideMenu toggle leftView
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeRefreshFlag), name: .shouldRefreshMainPageNutrition, object: nil)
        calorieFluidView = BAFluidView(frame: CGRect(x: 0, y: 0, width: calorieContainer.frame.width, height: calorieContainer.frame.height), startElevation: 0)
        calorieFluidView.fillColor = UIColor(red: 255/255, green: 240/255, blue: 240/255, alpha: 0.9)
        calorieFluidView.strokeColor = UIColor.white
        calorieFluidView.keepStationary()
        calorieFluidView.maxAmplitude = 8
        calorieFluidView.minAmplitude = 4
        calorieFluidView.fillDuration = 1
        calorieContainer.addSubview(calorieFluidView)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(jumpToNutritionPage))
        calorieFluidView.addGestureRecognizer(tapRecognizer)
        //check permission and set value for album access
        checkPhotoLibraryPermission()
        //analytic screen name
        Analytics.setScreenName("HomePage", screenClass: "HomeViewController")
    }

    @objc func jumpToNutritionPage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "nutritionInfoVC") as? DailyNutritionInfoViewController {
            controller.selectedDate = Date()
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }

    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            let preference = UserDefaults.standard
            preference.set(true, forKey: PreferenceKey.saveToAlbumFlag)
        //handle authorized status
        case .denied, .restricted :
            let preference = UserDefaults.standard
            preference.set(false, forKey: PreferenceKey.saveToAlbumFlag)
        //handle denied status
        case .notDetermined:
            // ask for permissions
            let preference = UserDefaults.standard
            preference.set(false, forKey: PreferenceKey.saveToAlbumFlag)
        }
    }

    //assemble the article & event list and display
    func loadArticle() {
        if ArticleDataManager.instance.articleList.count == 0 || ArticleDataManager.instance.eventList.count == 0 {
            APIService.instance.getArticleList(completion: { (_) in
                self.newsFeedTable.reloadData()
            }) {(_) in }
            APIService.instance.getEventList(completion: { (_) in
                self.newsFeedTable.reloadData()
            })
        }
    }

    @objc func changeRefreshFlag() {
        shouldRefreshMainPageNutrition = true
    }

    //load personal target whenever go to main page
    @objc func loadNutritionTarget() {
        APIService.instance.getDietGoal { (guideDict) in
            let preferences = UserDefaults.standard
            preferences.setValue(guideDict["energy"], forKey: PreferenceKey.calorieTarget)
            preferences.setValue(guideDict["carbohydrate"], forKey: PreferenceKey.carbohydrateTarget)
            preferences.setValue(guideDict["protein"], forKey: PreferenceKey.proteinTarget)
            preferences.setValue(guideDict["fat"], forKey: PreferenceKey.fatTarget)
            self.requestNutritionDict(requestDate: Date())
        }
    }

    func loadCalorieData(todayIntakenCal: Int) {
        let preferences = UserDefaults.standard
        let totalCal = Int(preferences.double(forKey: PreferenceKey.calorieTarget))
        totalCalorie.text = String(totalCal)
        intakenCalorie.text = String(todayIntakenCal)
        remainCalorie.text = String(totalCal-todayIntakenCal)
        if totalCal != 0 {
            let percentageValue = Int(todayIntakenCal*100/totalCal)
            percentageCalorie.text = String(percentageValue) + "%"
            calorieFluidView.fill(to: Float(percentageValue)/100 as NSNumber)
            calorieFluidView.startAnimation()
        } else {
            percentageCalorie.text = "0%"
            calorieFluidView.fill(to: 0 as NSNumber)
            calorieFluidView.startAnimation()
        }
    }

    //request when firstTime loading & add food into FoodCalendar by notificationCenter
    func requestNutritionDict(requestDate: Date) {
        APIService.instance.getDailySum(source: self, date: requestDate) { (resultDict) in
            if resultDict.count == 0 {
                return
            }
            self.assembleDisplayDict(nutritionDict: resultDict)
            self.assembleTargetDict()
            self.cpfCollectionView.reloadData()
            self.loadCalorieData(todayIntakenCal: Int(resultDict["energy"]!))
        }
    }

    func jumpToDestPage<T: UIViewController>(identifyId: String, mType: T.Type) {
        if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifyId) as? T {
            if let navigator = self.navigationController {
                if navigator.viewControllers.contains(where: {
                    return $0 is T
                }) {
                    for viewController in (self.navigationController?.viewControllers)! {
                        if let targetVC = viewController as? T {
                            DispatchQueue.main.async {
                                navigator.popToViewController(targetVC, animated: false)
                            }
                        }
                    }
                } else {
                    navigator.pushViewController(dest, animated: false)
                }
            }
        }
    }

    func assembleDisplayDict(nutritionDict: [String: Double]) {
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        newsFeedTable.reloadData()
    }

    //popUp dialog
    func popUpDialog() {
        AlertMessageHelper.showOkCancelDialog(targetController: self, title: "", message: "Please filling the profile page", postiveText: "To Profile Page", negativeText: "Stay At Home Page") { (isPositive) in
            if isPositive {
//                self.sideMenuController?.performSegue(withIdentifier: "MenutoProfile", sender: self)
                let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "personalProfileNaVVC")
                self.present(dest, animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //set status bar appearance
        UIApplication.shared.statusBarStyle = .lightContent
        //setUp title
        self.parent?.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 255/255, green: 80/255, blue: 110/255, alpha: 1)

        self.navigationController?.navigationBar.topItem?.title = StringConstants.NavigatorTitle.dietlensTitle
        //SignPainterHouseScript 28.0
        if let attributeGroup = [NSAttributedStringKey.foregroundColor: UIColor.white, kCTFontAttributeName: UIFont(name: "SignPainterHouseScript", size: 28)!] as? [NSAttributedStringKey: Any] {
            self.navigationController?.navigationBar.titleTextAttributes = attributeGroup
        }

        //disable homepage&LGMenu swipe back gesture
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        if shouldRefreshMainPageNutrition {
            loadNutritionTarget()
            shouldRefreshMainPageNutrition = false
        }

    }

    // calculate Nutrition Data & put into homePage
    func getDailyAccumulateCPF() {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func didPressArticle(_ indexOfArticleList: Int) {
        articleType = ArticleType.ARTICLE
        whichArticleIndex = indexOfArticleList
        if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "singleArticleVC") as? ArticleDetailViewController {
//            dest.articleType = self.articleType
            dest.articleData = ArticleDataManager.instance.articleList[indexOfArticleList]
            if let navigator = self.navigationController {
                navigator.pushViewController(dest, animated: true)
            }
        }
//        performSegue(withIdentifier: "presentArticlePage", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? ArticleDetailViewController {
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
        if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "singleArticleVC") as? ArticleDetailViewController {
            dest.articleData = ArticleDataManager.instance.eventList[indexPath.row - 1]
            if let navigator = self.navigationController {
                navigator.pushViewController(dest, animated: true)
            }
        }
//        performSegue(withIdentifier: "presentArticlePage", sender: self)
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

//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView == newsFeedTable {
//            let contentOffset = scrollView.contentOffset.y
//            if contentOffset > 0 {
//                cpfContainer.isHidden = true
//            } else {
//                cpfContainer.isHidden = false
//            }
//        }
//    }

    @objc func performSegueToArticleList() {
        articleType = ArticleType.ARTICLE
//        performSegue(withIdentifier: "showArticleList", sender: self)
        if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ArticleVC") as? ArticleViewController {
            dest.articleType = self.articleType
            if let navigator = self.navigationController {
                navigator.pushViewController(dest, animated: true)
            }
        }
    }

    @objc func performSegueToEventList() {
        articleType = ArticleType.EVENT
//        performSegue(withIdentifier: "showArticleList", sender: self)
        if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ArticleVC") as? ArticleViewController {
            dest.articleType = self.articleType
            if let navigator = self.navigationController {
                navigator.pushViewController(dest, animated: true)
            }
        }
    }

}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //CPF total 3 item
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cpfCollectionCell", for: indexPath) as? HomePageCPFCell {
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
            if indexPath.row == 0 {
                let progressBarColor = UIColor(red: 255/255, green: 183/255, blue: 32/255, alpha: 1)
                cell.setupCell(nutritionName: name, progressPercentage: progress, progressBarColor: progressBarColor )
            } else if indexPath.row == 1 {
                let progressBarColor = UIColor(red: 251/255, green: 137/255, blue: 69/255, alpha: 1)
                cell.setupCell(nutritionName: name, progressPercentage: progress, progressBarColor: progressBarColor )
            } else {
                let progressBarColor = UIColor(red: 248/255, green: 105/255, blue: 82/255, alpha: 1)
                cell.setupCell(nutritionName: name, progressPercentage: progress, progressBarColor: progressBarColor )
            }
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CGFloat(110), height: CGFloat(60))
    }

}
