//
//  RecognitionResultViewController.swift
//  DietLens
//
//  Created by linby on 10/04/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class RecognitionResultViewController: UIViewController {

    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var foodCategory: UICollectionView!
    @IBOutlet weak var foodOptionTable: UITableView!
    @IBOutlet weak var textSearchFloatingBtn: UIButton!
    @IBOutlet weak var animationView: UIView!

    //index & tracking data
    var categoryIndex = 0

    //view controller passing data
    var cameraImage: UIImage?
    var imageKey: String?
    var recordDate: Date = Date()
    var isSetMealByTimeRequired = false
    var mealType: String?

    //dataSource
    var foodCategoryList = [DisplayFoodCategory]()
    var selectedFoodInfo = DisplayFoodInfo()

    var previousOffset: CGFloat = CGFloat(0)

    override func viewDidLoad() {
        //get mockup data
//        mockUpCategoryData()
        foodImage.image = cameraImage
        foodOptionTable.delegate = self
        foodOptionTable.dataSource = self
        //add footerView
        let footerView = UIView()
        let seperatorLine = UIView()
        seperatorLine.frame = CGRect(x: 16, y: 0, width: foodOptionTable.fs_width, height: 0.5)
        seperatorLine.backgroundColor = UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1)
        footerView.addSubview(seperatorLine)
        footerView.fs_height = 60
        foodOptionTable.tableFooterView = footerView
        //food category delegate
        foodCategory.delegate = self
        foodCategory.dataSource = self
    }

    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }

    func mockUpCategoryData() {
        foodCategoryList = MockedUpFoodData.instance.createMockedUpFoodData()
    }

    @IBAction func toTextSearchPage(_ sender: Any) {
//        performSegue(withIdentifier: "toTextSearchPage", sender: nil)
        if let dest = UIStoryboard(name: "AddFoodScreen", bundle: nil).instantiateViewController(withIdentifier: "textInputVC") as? TextInputViewController {
            dest.cameraImage = cameraImage
            dest.imageKey = self.imageKey
            dest.shouldShowCancel = true
            //mealTime & mealType
            dest.mealType = self.mealType!
            dest.isSetMealByTimeRequired = self.isSetMealByTimeRequired
            dest.addFoodDate = recordDate
            if let navigator = self.navigationController {
                //clear controller to Bottom & add foodCalendar Controller
                navigator.pushViewController(dest, animated: true)
            }
        }
    }

    @IBAction func onBackPressed(_ sender: Any) {
         self.navigationController?.popViewController(animated: true)
    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let navVC = segue.destination as? UINavigationController
//        if let dest = navVC?.viewControllers.first as? FoodInfoViewController {
//            dest.userFoodImage = cameraImage
//            dest.isAccumulatedDiary = false
//            dest.imageKey = imageKey!
//            dest.foodId = selectedFoodInfo.id
//        }
//    }

    func requestForDietInformation(foodId: Int) {
        if foodId == 0 {
            return
        }
        AlertMessageHelper.showLoadingDialog(targetController: self)
        APIService.instance.getFoodDetail(foodId: foodId) { (dietItem) in
            AlertMessageHelper.dismissLoadingDialog(targetController: self) {
                if dietItem == nil {
                    return
                }
                var entity = dietItem!
                if entity.isMixFood {
                    self.redirectToFoodDiaryPage()
                    return
                }
                entity.recordType = RecognitionInteger.recognition
                if let dest = UIStoryboard(name: "AddFoodScreen", bundle: nil).instantiateViewController(withIdentifier: "FoodInfoVC") as? FoodInfoViewController {
                    dest.userFoodImage = self.cameraImage
                    dest.dietItem = entity
                    dest.recordType = entity.recordType
                    dest.imageKey = self.imageKey
                    //mealTime & mealType
                    dest.foodDiaryEntity.mealTime = DateUtil.normalDateToString(date: self.recordDate)
                    dest.isSetMealByTimeRequired = self.isSetMealByTimeRequired
                    dest.foodDiaryEntity.mealType = self.mealType!
                    if let navigator = self.navigationController {
                        //clear controller to Bottom & add foodCalendar Controller
                        navigator.pushViewController(dest, animated: true)
                    }
                }
            }
        }
    }

}

extension RecognitionResultViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodCategoryList[categoryIndex].subcateFoodList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recognitonResultCell") as? RecognitionResultTableCell
        let entity = foodCategoryList[categoryIndex].subcateFoodList[indexPath.row]
        let calorieValue = String(Int(entity.calories))+StringConstants.UIString.calorieUnit
        cell?.setUpCell(foodName: entity.displayName, imageUrl: entity.exampleImgUrl, calorieText: calorieValue, unitText: entity.unit)
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //jump to selected foodItem add FoodPage
        selectedFoodInfo = foodCategoryList[categoryIndex].subcateFoodList[indexPath.row]
        requestForDietInformation(foodId: selectedFoodInfo.id)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }

    func redirectToFoodDiaryPage() {
        if let dest = UIStoryboard(name: "AddFoodScreen", bundle: nil).instantiateViewController(withIdentifier: "FoodDiaryVC") as? FoodDiaryViewController {
            dest.userFoodImage = self.cameraImage
            dest.imageKey = self.imageKey
            dest.isMixVeg = true
            dest.isUpdate = false
            //mealTime & mealType
            dest.foodDiaryEntity.mealTime = DateUtil.normalDateToString(date: self.recordDate)
            dest.isSetMealByTimeRequired = self.isSetMealByTimeRequired
            dest.foodDiaryEntity.mealType = self.mealType!
            if let navigator = self.navigationController {
                //clear controller to Bottom & add foodCalendar Controller
                navigator.pushViewController(dest, animated: true)
            }
        }
    }

}

extension RecognitionResultViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return foodCategoryList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "foodCateogryCell", for: indexPath) as? FoodCategoryCollectionCell {
            cell.setUpCell(categoryName: foodCategoryList[indexPath.row].subcatName, categoryImageURL: foodCategoryList[indexPath.row].subcatImageUrl)
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //switch tab to show foodList
        categoryIndex = indexPath.row
        //move indicator to selected item
        let destX = (collectionView.cellForItem(at: indexPath)?.center.x)! - foodCategory.contentOffset.x
        UIView.animate(withDuration: 0.2) {
            self.animationView.center.x = destX
        }
        //table reload data
        foodOptionTable.reloadData()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        animationView.center.x += previousOffset - scrollView.contentOffset.x
        previousOffset = scrollView.contentOffset.x
    }

}
