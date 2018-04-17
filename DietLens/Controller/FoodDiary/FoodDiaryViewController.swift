//
//  FoodDiaryViewController.swift
//  DietLens
//
//  Created by linby on 10/04/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class FoodDiaryViewController: UIViewController {
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var mealTypeCollection: UICollectionView!
    @IBOutlet weak var foodTableView: UITableView!

    @IBOutlet weak var calorieValueLabel: UILabel!
    @IBOutlet weak var proteinValueLable: UILabel!
    @IBOutlet weak var fatValueLabel: UILabel!
    @IBOutlet weak var carbohydrateLabel: UILabel!

    //dataSource
    //append foodItem when it can be add
    var foodItemList = [FoodInfomation]()
    var accumulateCalorie: Double = 0.0
    var accumulateCabohydrate: Double = 0.0
    var accumulateProtein: Double = 0.0
    var accumulateFat: Double = 0.0
    //passing parameter
    var mealType: Meal = .breakfast
    //mealType data
    var mealStringArray = [StringConstants.MealString.breakfast, StringConstants.MealString.lunch, StringConstants.MealString.dinner, StringConstants.MealString.snack]
    var currentMealIndex = 0

    override func viewDidLoad() {
        mealTypeCollection.delegate = self
        mealTypeCollection.dataSource = self
        foodTableView.delegate = self
        foodTableView.dataSource = self
    }

}

extension FoodDiaryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mealStringArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if currentMealIndex == indexPath.row {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mealTypeCell", for: indexPath) as? MealTypeCollectionCell {
                cell.setUpCell(isHightLight: true, mealStr: mealStringArray[indexPath.row])
                return cell
            }
        } else {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mealTypeCell", for: indexPath) as? MealTypeCollectionCell {
                cell.setUpCell(isHightLight: false, mealStr: mealStringArray[indexPath.row])
                return cell
            }
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //change the mealType block selection
        currentMealIndex = indexPath.row
        let mealStr = mealStringArray[indexPath.row]
        switch mealStr {
        case StringConstants.MealString.breakfast:
            mealType = .breakfast
        case StringConstants.MealString.lunch:
            mealType = .lunch
        case StringConstants.MealString.dinner:
            mealType = .dinner
        case StringConstants.MealString.snack:
            mealType = .snack
        default:
            break
        }
        //switch collection selection
        mealTypeCollection.reloadData()
    }

}

extension FoodDiaryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodItemList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //name, portion calorie , deleteBtn
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FoodItemListCell") as? FoodItemListCell {
            let entity = foodItemList[indexPath.row]
            cell.setUpCell(foodName: entity.foodName, quantity: 1, unit: "portion", calorie: Double(entity.calorie))

        }
        return UITableViewCell()
    }

}

extension FoodDiaryViewController {
    //toTextSearchPage -> addmore, save to foodDiary, detail page to edit
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        
//    }
}
