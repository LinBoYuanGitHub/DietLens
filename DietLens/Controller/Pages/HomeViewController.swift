//
//  HomeViewController.swift
//  DietLens
//
//  Created by next on 24/10/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit
import RealmSwift
import BAFluidView
import Instructions

class HomeViewController: UIViewController, ArticleCollectionCellDelegate {

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

    //add coachMarks
    let coachMarksController = CoachMarksController()

    override func viewDidLoad() {
        super.viewDidLoad()
        //delegate for new table view
        newsFeedTable.dataSource = self
        newsFeedTable.delegate = self
        cpfCollectionView.delegate = self
        cpfCollectionView.dataSource = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        //change statusbarcolor
        newsFeedTable.tableHeaderView = headerView
        loadArticle()
        //for sideMenu toggle leftView
        NotificationCenter.default.addObserver(self, selector: #selector(self.onSideMenuClick(_:)), name: .onSideMenuClick, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeRefreshFlag), name: .shouldRefreshMainPageNutrition, object: nil)
        calorieFluidView = BAFluidView(frame: CGRect(x: 0, y: 0, width: calorieContainer.frame.width, height: calorieContainer.frame.height), startElevation: 0)
        calorieFluidView.fillColor = UIColor(red: 255/255, green: 240/255, blue: 240/255, alpha: 0.6)
        calorieFluidView.strokeColor = UIColor.white
        calorieFluidView.keepStationary()
        calorieFluidView.maxAmplitude = 8
        calorieFluidView.minAmplitude = 4
        calorieFluidView.fillDuration = 1
        calorieContainer.addSubview(calorieFluidView)
        //set instruction label dataSource
        self.coachMarksController.dataSource = self
        self.coachMarksController.overlay.color = UIColor(red: CGFloat(0), green: CGFloat(0), blue: CGFloat(0), alpha: 0.52)
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
        APIService.instance.getDietaryGuideInfo { (guideDict) in
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
        if totalCal != 0 {
            totalCalorie.text = String(totalCal)
            intakenCalorie.text = String(todayIntakenCal)
            remainCalorie.text = String(totalCal-todayIntakenCal)
            let percentageValue = Int(todayIntakenCal*100/totalCal)
            percentageCalorie.text = String(percentageValue) + "%"
            calorieFluidView.fill(to: Float(percentageValue)/100 as NSNumber)
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

    @objc func onSideMenuClick(_ notification: NSNotification) {
        guard let position = notification.userInfo?["position"] as? Int else {return}
        switch position {
        case 0:
            //home
            if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DietLens") as? HomeViewController {
                if let navigator = self.navigationController {
                    if navigator.viewControllers.contains(where: {
                        return $0 is HomeViewController
                    }) {
                        for viewController in (self.navigationController?.viewControllers)! {
                            if let homeVC = viewController as? HomeViewController {
                                DispatchQueue.main.async {
                                    navigator.popToViewController(homeVC, animated: false)
                                }
                            }
                        }
                    } else {
                        navigator.pushViewController(dest, animated: false)
                    }
                }
            }
        case 1:
            //to food diary page
            if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FoodDiaryHistoryVC") as? FoodDiaryHistoryViewController {
                if let navigator = self.navigationController {
                    if navigator.viewControllers.contains(where: {
                        return $0 is FoodDiaryHistoryViewController
                    }) {
                        for viewController in (self.navigationController?.viewControllers)! {
                            if let targetVC = viewController as? FoodDiaryHistoryViewController {
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
        case 2:
            //to step counter page
            if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StepCounterVC") as? StepCounterViewController {
                if let navigator = self.navigationController {
                    if navigator.viewControllers.contains(where: {
                        return $0 is StepCounterViewController
                    }) {
                        for viewController in (self.navigationController?.viewControllers)! {
                            if let targetVC = viewController as? StepCounterViewController {
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
        case 3:
            //to healthCenter page
            if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "healthCenterVC") as? HealthCenterMainViewController {
                if let navigator = self.navigationController {
                    if navigator.viewControllers.contains(where: {
                        return $0 is HealthCenterMainViewController
                    }) {
                        for viewController in (self.navigationController?.viewControllers)! {
                            if let targetVC = viewController as? HealthCenterMainViewController {
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
        case 4:
            //to setting page
            if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsPage") as? SettingViewController {
                if let navigator = self.navigationController {
                    if navigator.viewControllers.contains(where: {
                        return $0 is SettingViewController
                    }) {
                        for viewController in (self.navigationController?.viewControllers)! {
                            if let targetVC = viewController as? SettingViewController {
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
        default:
            break
        }
        self.sideMenuController?.hideLeftView(animated: true, completionHandler: nil)
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        newsFeedTable.reloadData()
        let preferences = UserDefaults.standard
        let shouldPopUpFlag = !preferences.bool(forKey: FirstTimeFlag.shouldPopUpProfilingDialog)
        if shouldPopUpFlag {
            popUpDialog()
            preferences.set(true, forKey: FirstTimeFlag.shouldPopUpProfilingDialog)
        }
        //show markView for tap
//        let shouldShowCoachMark = !preferences.bool(forKey: FirstTimeFlag.isNotFirstTimeViewHome)
//        if shouldShowCoachMark {
//            self.coachMarksController.start(on: self)
//            preferences.set(true, forKey: FirstTimeFlag.isNotFirstTimeViewHome)
//        }
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
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.topItem?.title = StringConstants.NavigatorTitle.dietlensTitle
        //SignPainterHouseScript 28.0
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, kCTFontAttributeName: UIFont(name: "SignPainterHouseScript", size: 28)!] as! [NSAttributedStringKey: Any]
        self.navigationController?.navigationBar.barTintColor = UIColor(red: CGFloat(240.0/255.0), green: CGFloat(90.0/255.0), blue: CGFloat(90.0/255.0), alpha: 1.0)
        //backbtn
        self.sideMenuController?.isLeftViewSwipeGestureEnabled = true
        if shouldRefreshMainPageNutrition {
            loadNutritionTarget()
            shouldRefreshMainPageNutrition = false
        }
    }

    // calculate Nutrition Data & put into homePage
    func getDailyAccumulateCPF() {
    }

    @IBAction func presentCamera(_ sender: UIButton) {
        if let dest = UIStoryboard(name: "AddFoodScreen", bundle: nil).instantiateInitialViewController() as? AddFoodViewController {
            if let navigator = self.navigationController {
                //clear controller to Bottom & add foodCalendar Controller
                let transition = CATransition()
                transition.duration = 0.3
                transition.type = kCATransitionMoveIn
                transition.subtype = kCATransitionFromTop
                self.view.window?.layer.add(transition, forKey: kCATransition)
//                self.navigationController?.view.layer.add(transition, forKey: kCATransition)
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
        if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "singleArticleVC") as? SingleArticleViewController {
//            dest.articleType = self.articleType
            dest.articleData = ArticleDataManager.instance.articleList[indexOfArticleList]
            if let navigator = self.navigationController {
                navigator.pushViewController(dest, animated: true)
            }
        }
//        performSegue(withIdentifier: "presentArticlePage", sender: self)
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
        if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "singleArticleVC") as? SingleArticleViewController {
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

extension HomeViewController: CoachMarksControllerDataSource, CoachMarksControllerDelegate {

    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        coachViews.bodyView.nextLabel.text = "Got it"
        coachViews.bodyView.hintLabel.text = " Tap to start "
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }

    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        return coachMarksController.helper.makeCoachMark(for: homePlusButton)
    }

    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 1
    }

}
