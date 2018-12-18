//
//  PersonalFavouriteFoodViewController.swift
//  DietLens
//
//  Created by linby on 2018/11/22.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class PersonalFavouriteFoodViewController: BaseViewController {

    @IBOutlet weak var popularCollectionView: UICollectionView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!

    //data struct
    var favouriteFoodIdList = [Int]() //pass id to favourite
    var popularFoodList = [TextSearchSuggestionEntity]()

    //registration flow param
    var isInRegistrationFlow = false

    override func viewDidLoad() {
        popularCollectionView.dataSource = self
        popularCollectionView.delegate = self
        //request popular food data
        getPopularFoodList(mealtime: "")
        //regist nib
        registerNib()
        progressLabel.isHidden = !isInRegistrationFlow
        progressView.isHidden = !isInRegistrationFlow
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationItem.title = StringConstants.UIString.FilterFavorite
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Back Arrow"), style: .plain, target: self, action: #selector(onBackPressed))
        self.navigationItem.leftBarButtonItem?.tintColor = .gray
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Skip", style: .plain, target: self, action: #selector(onDonePressed))
        self.navigationItem.rightBarButtonItem?.tintColor = .gray
    }

    func registerNib() {
        let collectionNib = UINib(nibName: "FavouriteFoodCollectionCell", bundle: nil)
        popularCollectionView.register(collectionNib, forCellWithReuseIdentifier: "favouriteFoodCollectionCell")
    }

    func getPopularFoodList(mealtime: String) {
        APIService.instance.getFoodSearchPopularity(mealtime: mealtime, completion: { (textResults) in
            guard let results =  textResults else {
                return
            }
            self.popularFoodList = results
            self.popularCollectionView.reloadData()
        }, nextPageCompletion: { (_) in
            //consider next page scenario
        })
    }

    @objc func onBackPressed() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc func onDonePressed() {
        if favouriteFoodIdList.count != 0 {
            APIService.instance.setFavouriteFoodList(foodList: favouriteFoodIdList) { (isSuccess) in
                if isSuccess {
                    self.redirectToFinalRegistrationPage()
                }
            }
        } else {
            redirectToFinalRegistrationPage()
        }
    }

    func redirectToFinalRegistrationPage() {
        if self.isInRegistrationFlow {
            if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "calorieGoalVC") as? CalorieGoalViewController {
                dest.isInRegistrationFlow = true
                self.navigationController?.pushViewController(dest, animated: true)
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }

}

extension PersonalFavouriteFoodViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return popularFoodList.count>9 ? 9:popularFoodList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //same cell style
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favouriteFoodCollectionCell", for: indexPath) as? RegistrationFavouriteFoodCell {
            cell.setUpCell(entity: popularFoodList[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //mark the item that is selected
        guard let targetCell = collectionView.cellForItem(at: indexPath) as? RegistrationFavouriteFoodCell else {
            return
        }
        //toggle the selection
        let foodId = popularFoodList[indexPath.row].id
        //toggle
        if let id = favouriteFoodIdList.firstIndex(of: foodId) {
            favouriteFoodIdList.remove(at: id)
            targetCell.toggleFavIcon(isFav: false)
        } else {
            favouriteFoodIdList.append(foodId)
            targetCell.toggleFavIcon(isFav: true)
        }
        if favouriteFoodIdList.count == 0 {
            self.navigationItem.rightBarButtonItem?.title = "Skip"
        } else {
            self.navigationItem.rightBarButtonItem?.title = "Done"
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 120)
    }

}
