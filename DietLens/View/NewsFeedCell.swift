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
    weak var pressArticleDelegate: ArticleCollectionCellDelegate?

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
        if listOfArticles.count >= 3 {
            return 3
        } else {
            return listOfArticles.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "articleCell", for: indexPath) as? NewsArticleCell {
            //add hyphenation text
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.hyphenationFactor = 1.0
            let attributedString = NSMutableAttributedString(string: listOfArticles[indexPath.row].articleTitle, attributes: [NSAttributedStringKey.paragraphStyle: paragraphStyle])
            cell.newsTitle.attributedText = attributedString
//            cell.newsTitle.text = listOfArticles[indexPath.row].articleTitle
            cell.newsImage.image = #imageLiteral(resourceName: "loading_img")
            if listOfArticles[indexPath.row].articleImageURL != ""{
                let imageView = UIImageView()
                imageView.af_setImage(withURL: URL(string: listOfArticles[indexPath.row].articleImageURL)!, placeholderImage: #imageLiteral(resourceName: "loading_img"), filter: nil, imageTransition: .crossDissolve(0.5), completion: { _ in
                    cell.newsImage.image = imageView.image
                })
            }
            return cell
        } else {
            return NewsArticleCell()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selecting \(indexPath.item)")
        pressArticleDelegate!.didPressArticle(indexPath.item)
    }

    func setupNewsArticleRow(articles: [Article], whichVCisDelegate: ArticleCollectionCellDelegate?) {
        listOfArticles = articles
        pressArticleDelegate = whichVCisDelegate
    }

}
