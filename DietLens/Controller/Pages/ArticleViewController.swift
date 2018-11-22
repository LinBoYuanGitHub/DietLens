//
//  ArticleViewController.swift
//  DietLens
//
//  Created by next on 11/11/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit
import Reachability
import FirebaseAnalytics

class ArticleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var articleTable: UITableView!
    @IBOutlet weak var articleTitle: UILabel!
    @IBOutlet weak var emptyView: UIView!

    var articleDataSource: [Article] = ArticleDataManager.instance.articleList
    public var articleType = ArticleType.ARTICLE
    //pagination flag
    var isLoading = false
    var nextPageLink = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        articleTable.dataSource = self
        articleTable.delegate = self
        articleTable.estimatedRowHeight = 90
        articleTable.rowHeight = UITableViewAutomaticDimension
        if articleType == ArticleType.ARTICLE {
            articleDataSource = ArticleDataManager.instance.articleList
            articleTitle.text = "Latest articles"
            //analytic screen name
            Analytics.setScreenName("LatestArticles", screenClass: "ArticleViewController")
        } else if articleType == ArticleType.EVENT {
            articleDataSource = ArticleDataManager.instance.eventList
            articleTitle.text = "Latest health events"
            //analytic screen name
            Analytics.setScreenName("LatestEvents", screenClass: "ArticleViewController")
        }
        // Do any additional setup after loading the view.
        articleTable.tableFooterView = LoadingFooterView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 52))
        articleTable.tableFooterView?.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.tintColor = UIColor.clear
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    override func viewDidAppear(_ animated: Bool) {
        if articleDataSource.count == 0 {
            //networking judegement
            refresh()
        }
    }

    @IBAction func onRefreshBtnPressed(_ sender: UIButton) {
        emptyView.isHidden = true
        refresh()
    }

    func refresh() {
        if Reachability()!.connection == .none {
            emptyView.isHidden = false
            return
        }
        AlertMessageHelper.showLoadingDialog(targetController: self)
        if articleType == ArticleType.ARTICLE {
            APIService.instance.getArticleList(completion: { (articleList) in
                AlertMessageHelper.dismissLoadingDialog(targetController: self) {
                    if articleList == nil {
                        return
                    }
                    self.articleDataSource = articleList!
                    ArticleDataManager.instance.articleList = articleList!
                    self.articleTable?.reloadData()
                }
            }) { (nextLink) in
                if self.nextPageLink == nil {
                    self.nextPageLink = ""
                } else {
                    self.nextPageLink = nextLink
                }
            }
        } else if articleType == ArticleType.EVENT {
            APIService.instance.getEventList(completion: { (eventList) in
                if eventList == nil {
                    return
                }
                self.articleDataSource = eventList!
                ArticleDataManager.instance.eventList = eventList!
                self.articleTable?.reloadData()
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if articleType == ArticleType.ARTICLE {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell") as? NewsArticleTableCell {
                cell.setupCell(imageURL: articleDataSource[indexPath.row].articleImageURL, title: articleDataSource[indexPath.row].articleTitle, source: articleDataSource[indexPath.row].source, dateStr: "March 27, 2018")
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell") as?
                NewsEventCell {
                cell.setupCell(imageURL: articleDataSource[indexPath.row].articleImageURL, title: articleDataSource[indexPath.row].articleTitle, source: articleDataSource[indexPath.row].source, dateStr: "March 27, 2018")
                return cell
            }
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        performSegue(withIdentifier: "presentArticlePage", sender: self)
        if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "singleArticleVC") as? SingleArticleViewController {
            if articleType == ArticleType.ARTICLE {
                dest.articleData = ArticleDataManager.instance.articleList[indexPath.row]
            } else {
                dest.articleData = ArticleDataManager.instance.eventList[indexPath.row]
            }
            if let navigator = self.navigationController {
                navigator.pushViewController(dest, animated: true)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //TODO set different height for article & event
        if articleType == ArticleType.ARTICLE {
            return 247
        } else {
            return 290
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articleDataSource.count
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let  height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            if nextPageLink == "" || isLoading {
                return
            }
            articleTable.tableFooterView?.isHidden = true
            self.isLoading = false
            APIService.instance.getArticleList(link: nextPageLink, completion: { (articleList) in
                self.articleTable.tableFooterView?.isHidden = true
                self.isLoading = false
                if articleList == nil {
                    return
                }
                for article in articleList! {
                     ArticleDataManager.instance.articleList.append(article)
                }
                self.articleTable.reloadData()
            }, nextLinkCompletion: { (nextLink) in
                if nextLink == nil {
                    self.nextPageLink = ""
                } else {
                    self.nextPageLink = nextLink
                }
            })
        }
    }

    @IBAction func backButtonPressed(_ sender: Any) {
//        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let article: Article = articleDataSource[(articleTable.indexPathForSelectedRow?.row)!]
        if let dest = segue.destination as? SingleArticleViewController {
            dest.articleData = article
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
