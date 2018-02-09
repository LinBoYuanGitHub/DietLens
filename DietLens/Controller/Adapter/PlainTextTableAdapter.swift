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
        if section == 0 {
            if isShowIngredient {
                return "Ingredients (per serve)"
            } else {
                return "Nutrients (per serve)"
            }
        } else {
            return "Nutrients (per serve)"
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
        if section == 0 {
            if isShowIngredient {
                let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "IngredientSectionHeader")
                let header = cell as! IngredientSectionHeader
                header.titleLabel.text = "Ingredient (per serve)"
                if isShowPlusBtn {
                    header.plusButton.isHidden = false
                } else {
                    header.plusButton.isHidden = true
                }
                return cell
            } else {
                return UITableViewHeaderFooterView()
            }
        } else {
            return UITableViewHeaderFooterView()
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
