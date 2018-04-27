//
//  FoodDiaryViewController.swift
//  DietLens
//
//  Created by linby on 10/04/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class FoodDiaryViewController: UIViewController {

    @IBOutlet weak var foodSampleImage: UIImageView!
    @IBOutlet weak var mealCollectionView: UICollectionView!
    @IBOutlet weak var foodTableView: UITableView!
    //sum nutritionPart
    @IBOutlet weak var calorieValueLabel: UILabel!
    @IBOutlet weak var proteinValueLable: UILabel!
    @IBOutlet weak var fatValueLabel: UILabel!
    @IBOutlet weak var carbohydrateLabel: UILabel!
    //table header: foodImage,mealTypeView,nutritionView

    //dataSource
    var foodDiaryEntity = FoodDiaryEntity()
    //passing parameter
    var userFoodImage: UIImage?
    //mealType data
    var mealStringArray = [StringConstants.MealString.breakfast, StringConstants.MealString.lunch, StringConstants.MealString.dinner, StringConstants.MealString.snack]
    var currentMealIndex = 0

    override func viewDidLoad() {
        mealCollectionView.delegate = self
        mealCollectionView.dataSource = self
        foodTableView.delegate = self
        foodTableView.dataSource = self
        foodSampleImage.image = userFoodImage
        //registration for resuable nib cellItem
        mealCollectionView.register(MealTypeCollectionCell.self, forCellWithReuseIdentifier: "mealTypeCell")
        mealCollectionView.register(UINib(nibName: "MealTypeCollectionCell", bundle: nil), forCellWithReuseIdentifier: "mealTypeCell")
        initFoodInfo()

    }

    func initFoodInfo() {
        calculateAccumulateFoodValue()
    }

    func calculateAccumulateFoodValue() {
        var accumulatedCalorie = 0
        var accumulatedCarbohydrate = 0
        var accumulatedProtein = 0
        var accumulatedFat = 0
        //get accumualted value
        for dietItem in foodDiaryEntity.dietItems {
            accumulatedCalorie += Int(dietItem.nutritionInfo.calorie)
            accumulatedCarbohydrate += Int(dietItem.nutritionInfo.carbohydrate)
            accumulatedProtein += Int(dietItem.nutritionInfo.protein)
            accumulatedFat += Int(dietItem.nutritionInfo.fat)
        }
        calorieValueLabel.text = String(accumulatedCalorie) + StringConstants.UIString.calorieUnit
        carbohydrateLabel.text = String(accumulatedCarbohydrate) + StringConstants.UIString.diaryIngredientUnit
        proteinValueLable.text = String(accumulatedProtein) + StringConstants.UIString.diaryIngredientUnit
        fatValueLabel.text = String(accumulatedFat) + StringConstants.UIString.diaryIngredientUnit
    }

    func updateFoodDiary() {
        APIService.instance.updateFoodDiary(foodDiary: foodDiaryEntity) { (isSuccess) in
                if isSuccess {
                    if (self.navigationController?.viewControllers.contains(where: {
                        return $0 is FoodInfoViewController
                    }))! {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
        }
    }

    func addFoodIntoItem(dietItem: DietItem) {
        foodDiaryEntity.dietItems.append(dietItem)
    }

}

extension FoodDiaryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
        foodDiaryEntity.mealType = mealStringArray[indexPath.row]
        //switch collection selection
        mealCollectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CGFloat(70), height: CGFloat(35))
    }

}

extension FoodDiaryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodDiaryEntity.dietItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //name, portion calorie , deleteBtn
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FoodItemListCell") as? FoodItemListCell {
            let entity = foodDiaryEntity.dietItems[indexPath.row]
            cell.setUpCell(dietItem: entity)
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //API delete item
            self.foodDiaryEntity.dietItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

}

extension FoodDiaryViewController {
    //toTextSearchPage -> addmore, save to foodDiary, detail page to edit
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        
//    }
}
