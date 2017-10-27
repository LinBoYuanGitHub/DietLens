//
//  NewsFeedCell.swift
//  DietLens
//
//  Created by next on 24/10/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit

class NewsFeedCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate
{
    @IBOutlet weak var NewsArticleRow: UICollectionView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        NewsArticleRow.dataSource = self
        NewsArticleRow.delegate = self
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "articleCell", for: indexPath) as? NewsArticleCell
        {
            return cell
        }
        else
        {
            return NewsArticleCell()
        }
    }
    
    
}


