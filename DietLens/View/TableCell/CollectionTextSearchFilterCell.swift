//
//  collectionTextFilterCell.swift
//  DietLens
//
//  Created by linby on 05/04/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
class CollectionTextSearchFilterCell: UICollectionViewCell {

    @IBOutlet weak var filterLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setUpCell(filterText: String) {
        self.filterLabel.text = filterText
    }

}
