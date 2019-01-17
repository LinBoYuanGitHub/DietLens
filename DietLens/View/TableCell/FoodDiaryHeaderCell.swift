//
//  FoodDiaryHeaderCell.swift
//  DietLens
//
//  Created by next on 7/11/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit

class FoodDiaryHeaderCell: UITableViewCell {

    typealias SwiftBlock = (_ meal: Meal) -> Void
    var callBack: SwiftBlock?
    @IBOutlet weak var titleLabel: UILabel!
    var meal: Meal = .breakfast

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func callBackBlock(block: @escaping SwiftBlock) {
        callBack = block
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func setupHeaderCell(whichMeal: Meal) {
        meal = whichMeal
        switch whichMeal {
        case .breakfast:
            titleLabel.text = "Breakfast"
        case .lunch:
            titleLabel.text = "Lunch"
        case .dinner:
            titleLabel.text = "Dinner"
        case .snack:
            titleLabel.text = "Snack"
        }
    }

    @IBAction func buttonPressed(_ sender: UIButton) {
        if callBack != nil {
            callBack!(meal)
        }
    }
}
