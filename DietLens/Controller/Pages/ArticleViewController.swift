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
    public let articleDatamanager = ArticleDataManager.instance

    override func viewDidLoad() {
        super.viewDidLoad()
        articleTable.dataSource = self
        articleTable.delegate = self
        articleTable.estimatedRowHeight = 90
        articleTable.rowHeight = UITableViewAutomaticDimension
        // Do any additional setup after loading the view.
         APIService.instance.getArticleList(completion: { (articleList) in
            self.articleDatamanager.articleList = articleList!
            self.articleTable?.reloadData()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell") as? NewsArticleTableCell {
            cell.setupCell(imageURL: articleDatamanager.articleList[indexPath.row].articleImageURL, title: articleDatamanager.articleList[indexPath.row].articleTitle, description: articleDatamanager.articleList[indexPath.row].articleContent)
                return cell
            }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "presentArticlePage", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articleDatamanager.articleList.count
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var article: Article = articleDatamanager.articleList[(articleTable.indexPathForSelectedRow?.row)!]
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
