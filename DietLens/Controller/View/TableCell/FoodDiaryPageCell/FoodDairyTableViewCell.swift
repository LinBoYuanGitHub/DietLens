//
//  FoodDairyCollectionViewCell.swift
//  DietLens
//
//  Created by linby on 2018/6/22.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

protocol FoodDiaryTableCellDelegate {

    func didSelectFoodDiaryItem(foodDiary: FoodDiaryEntity)

    func toggleFoodDiaryTrashItem(foodDiaryId: String, isAddedToTrash: Bool)

    func didEnterAddFoodPage(mealPos: Int)

}

class FoodDairyTableViewCell: UITableViewCell {

    @IBOutlet weak var foodDiaryCollection: UICollectionView!
    var foodDiaryList = [FoodDiaryEntity]()
    var delegate: FoodDiaryTableCellDelegate?
    var currentEditStatus: FoodDiaryStatus?
    var mealSection = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        self.foodDiaryCollection.delegate = self
        self.foodDiaryCollection.dataSource = self
        self.foodDiaryCollection.contentInset = UIEdgeInsets(top: 3, left: 16, bottom: 0, right: 16)
    }

    func setUpCell(foodDiaryList: [FoodDiaryEntity], currentEditStatus: FoodDiaryStatus, delegate: FoodDiaryTableCellDelegate) {
        self.foodDiaryList = foodDiaryList
        self.delegate = delegate
        self.currentEditStatus = currentEditStatus
        foodDiaryCollection.reloadData()
    }

}

extension FoodDairyTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return foodDiaryList.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == foodDiaryList.count {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addMoreCollectionCell", for: indexPath) as? UICollectionViewCell {
                return cell
            }
        } else {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "foodDiaryCollectionCell", for: indexPath) as? FoodDiaryCollectionViewCell {
                cell.setUpCell(foodDiary: foodDiaryList[indexPath.row])
                if currentEditStatus == FoodDiaryStatus.edit {
                    cell.showEdit()
                } else {
                    cell.hideEdit()
                }
                return cell
            }
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 68, height: 68)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(16)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(16)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == foodDiaryList.count {
            delegate?.didEnterAddFoodPage(mealPos: mealSection)
        } else {
            if currentEditStatus == .edit {
                if let cell = collectionView.cellForItem(at: indexPath) as? FoodDiaryCollectionViewCell {
                    let flag = cell.toggleTick()
                    delegate?.toggleFoodDiaryTrashItem(foodDiaryId: foodDiaryList[indexPath.row].foodDiaryId, isAddedToTrash: flag)
                }
            } else {
                 delegate?.didSelectFoodDiaryItem(foodDiary: foodDiaryList[indexPath.row])
            }

        }

    }

}
