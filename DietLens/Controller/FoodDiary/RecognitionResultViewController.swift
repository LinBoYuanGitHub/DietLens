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

    //index & tracking data
    var categoryIndex = 0

    //view controller passing data
    var cameraImage: UIImage?
    var imageKey: String?
    var recordDate: Date = Date()
    var isSetMealByTimeRequired = false

    //dataSource
    var foodCategoryList = [DisplayFoodCategory]()
    var selectedFoodInfo = DisplayFoodInfo()

    override func viewDidLoad() {
        //get mockup data
//        mockUpCategoryData()
        foodImage.image = cameraImage
        foodOptionTable.delegate = self
        foodOptionTable.dataSource = self
        foodCategory.delegate = self
        foodCategory.dataSource = self
    }

    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }

    func mockUpCategoryData() {
        foodCategoryList = MockedUpFoodData.instance.createMockedUpFoodData()
    }

    @IBAction func onSaveBtnClicked(_ sender: Any) {
        //save image only , create empty foodDiary
    }

    @IBAction func toTextSearchPage(_ sender: Any) {
//        performSegue(withIdentifier: "toTextSearchPage", sender: nil)
        if let dest = UIStoryboard(name: "AddFoodScreen", bundle: nil).instantiateViewController(withIdentifier: "textInputVC") as? TextInputViewController {
            dest.addFoodDate = recordDate
            dest.cameraImage = cameraImage
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
        APIService.instance.getFoodDetail(foodId: foodId) { (dietItem) in
            if dietItem == nil {
                return
            }
            var entity = dietItem!
            entity.recordType = RecognitionInteger.recognition
            if let dest = UIStoryboard(name: "AddFoodScreen", bundle: nil).instantiateViewController(withIdentifier: "FoodInfoVC") as? FoodInfoViewController {
                dest.userFoodImage = self.cameraImage
                dest.dietItem = entity
                dest.recordType = entity.recordType
                dest.imageKey = self.imageKey
                dest.isSetMealByTimeRequired = self.isSetMealByTimeRequired
                if let navigator = self.navigationController {
                    //clear controller to Bottom & add foodCalendar Controller
                    navigator.pushViewController(dest, animated: true)
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
        let calorieValue = String(foodCategoryList[categoryIndex].subcateFoodList[indexPath.row].calories)+StringConstants.UIString.calorieUnit
        cell?.setUpCell(foodName: foodCategoryList[categoryIndex].subcateFoodList[indexPath.row].displayName, imageUrl: foodCategoryList[categoryIndex].subcateFoodList[indexPath.row].exampleImgUrl, calorieText: calorieValue)
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //jump to selected foodItem add FoodPage
        selectedFoodInfo = foodCategoryList[categoryIndex].subcateFoodList[indexPath.row]
        requestForDietInformation(foodId: selectedFoodInfo.id)
//        if let dest = UIStoryboard(name: "AddFoodScreen", bundle: nil).instantiateViewController(withIdentifier: "FoodInfoVC") as? FoodInfoViewController {
//            dest.userFoodImage = cameraImage
//            if let navigator = self.navigationController {
//                navigator.pushViewController(dest, animated: true)
//
//            }
//        }
//        performSegue(withIdentifier: "toRecognizedFoodPage", sender: nil)
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
        //table reload data
        foodOptionTable.reloadData()
    }

}
