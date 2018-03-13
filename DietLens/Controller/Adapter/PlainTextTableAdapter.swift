//
//  PlainTextTableAdapter.swift
//  DietLens
//
//  Created by linby on 07/12/2017.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation
import UIKit

class PlainTextTableAdapter<CellType: UITableViewCell>: NSObject, UITableViewDataSource, UITableViewDelegate {
    public var nutritionTextList = [String]()
    public var ingredientTextList = [String]()
    public var isShowIngredient = false
    public var isShowPlusBtn = true

    public var totalWeight: Double = 0

    public var callBack: ((Int) -> Void)?

    override init() {
        super.init()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if (isShowIngredient) {
            return 2
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if isShowIngredient {
                return ingredientTextList.count
            } else {
                return nutritionTextList.count
            }
        } else {
            return nutritionTextList.count
        }

    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 && isShowIngredient {
            return StringConstants.UIString.IngredientHeaderText
        } else {
            return StringConstants.UIString.NutritionHeaderText + "(\(totalWeight)"+StringConstants.UIString.diaryIngredientUnit+")"
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UITableViewHeaderFooterView()
        view.contentView.backgroundColor = UIColor.white
        view.backgroundColor = UIColor.white
        return view
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "IngredientSectionHeader") as? IngredientSectionHeader, section == 0, isShowIngredient else {
                return UITableViewHeaderFooterView()
        }

        header.titleLabel.text = StringConstants.UIString.IngredientHeaderText
        header.plusButton.isHidden = !isShowPlusBtn
        return header
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let nutritionCell = tableView.dequeueReusableCell(withIdentifier: "nutritionItemCell") as? UITableViewCell else{
//            guard let ingredientCell =  tableView.dequeueReusableCell(withIdentifier: "ingredientItemCell") as? IngredientItemCell, indexPath.section == 0,isShowIngredient else {
//                nutritionCell.textLabel?.text = "\(nutritionTextList[indexPath.row])"
//                return nutritionCell
//            }
//            ingredientCell.setUpCell(ingredientName: ingredientTextList[indexPath.row])
//            ingredientCell.deleteBtn.tag = indexPath.row
//            ingredientCell.deleteBtn.addTarget(self, action: #selector(deleteIngredient(_:)), for: .touchUpInside)
//            return ingredientCell
//        }
//        nutritionCell.textLabel?.text = "\(nutritionTextList[indexPath.row])"
//        return nutritionCell
        var cell = tableView.dequeueReusableCell(withIdentifier: "nutritionItemCell") //UITableViewCell()
        if indexPath.section == 0 {
            if isShowIngredient {
                if isShowPlusBtn {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ingredientItemCell") as? IngredientItemCell
                    (cell as? IngredientItemCell)?.setUpCell(ingredientName: ingredientTextList[indexPath.row])
                    cell?.deleteBtn.tag = indexPath.row
                    cell?.deleteBtn.addTarget(self, action: #selector(deleteIngredient(_:)), for: .touchUpInside)
                    return cell!
                } else {
                    cell?.textLabel?.text = "\(ingredientTextList[indexPath.row])"
                }
            } else {
                cell?.textLabel?.text = "\(nutritionTextList[indexPath.row])"
            }
        } else {
            cell?.textLabel?.text = "\(nutritionTextList[indexPath.row])"
        }
        return cell!
    }

    @objc func deleteIngredient(_ sender: UIButton) {
        let index = sender.tag
        if callBack != nil {
            callBack!(index)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}
