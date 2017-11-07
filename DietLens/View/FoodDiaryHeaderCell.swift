//
//  FoodDiaryHeaderCell.swift
//  DietLens
//
//  Created by next on 7/11/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit

class FoodDiaryHeaderCell: UITableViewCell {
    weak var addFoodDelegate: DiaryHeaderCellDelegate?
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func buttonPressed(_ sender: UIButton)
    {
        addFoodDelegate?.didPressAddButton(1)
    }
}
