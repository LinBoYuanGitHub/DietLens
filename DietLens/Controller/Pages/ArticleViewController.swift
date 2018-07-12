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
    @IBOutlet weak var articleTitle: UILabel!
    var articleDataSource: [Article] = ArticleDataManager.instance.articleList
    public var articleType = ArticleType.ARTICLE

    override func viewDidLoad() {
        super.viewDidLoad()
        articleTable.dataSource = self
        articleTable.delegate = self
        articleTable.estimatedRowHeight = 90
        articleTable.rowHeight = UITableViewAutomaticDimension
        if articleType == ArticleType.ARTICLE {
            articleDataSource = ArticleDataManager.instance.articleList
            articleTitle.text = "Latest articles"
        } else if articleType == ArticleType.EVENT {
            articleDataSource = ArticleDataManager.instance.eventList
            articleTitle.text = "Latest healthy events"
        }
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.tintColor = UIColor.clear
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.sideMenuController?.isLeftViewSwipeGestureEnabled = false
    }

    override func viewDidAppear(_ animated: Bool) {
        let alertController = UIAlertController(title: nil, message: "Loading...\n\n", preferredStyle: UIAlertControllerStyle.alert)
        if articleDataSource.count == 0 {
            AlertMessageHelper.showLoadingDialog(targetController: self)
            self.present(alertController, animated: false, completion: nil)
            if articleType == ArticleType.ARTICLE {
                APIService.instance.getArticleList(completion: { (articleList) in
                    AlertMessageHelper.dismissLoadingDialog(targetController: self) {
                        if articleList == nil {
                            return
                        }
                        ArticleDataManager.instance.articleList = articleList!
                        self.articleTable?.reloadData()
                    }
                })
            } else if articleType == ArticleType.EVENT {
                APIService.instance.getEventList(completion: { (eventList) in
                    alertController.dismiss(animated: true, completion: nil)
                    if eventList == nil {
                        return
                    }
                    ArticleDataManager.instance.eventList = eventList!
                    self.articleTable?.reloadData()
                })
            }
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
        performSegue(withIdentifier: "presentArticlePage", sender: self)
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
