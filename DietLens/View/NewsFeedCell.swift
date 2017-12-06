//
//  NewsFeedCell.swift
//  DietLens
//
//  Created by next on 24/10/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit
import AlamofireImage

class NewsFeedCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var newsArticleRow: UICollectionView!

    var listOfArticles = [Article]()
    override func awakeFromNib() {
        super.awakeFromNib()
        newsArticleRow.dataSource = self
        newsArticleRow.delegate = self

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "articleCell", for: indexPath) as? NewsArticleCell {
            cell.newsTitle.text = listOfArticles[indexPath.row].articleTitle
            cell.newsImage.image = #imageLiteral(resourceName: "loading_img")
            cell.newsImage.af_setImage(withURL: URL(string: listOfArticles[indexPath.row].articleImageURL)!)

            return cell
        } else {
            return NewsArticleCell()
        }
    }

    func setupNewsArticleRow(articles: [Article]) {
        listOfArticles = articles
    }

}
