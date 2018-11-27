//
//  PersonalFavouriteFoodViewController.swift
//  DietLens
//
//  Created by linby on 2018/11/22.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class PersonalFavouriteFoodViewController: BaseViewController {

    @IBOutlet weak var breakfastCollectionView: UICollectionView!
    @IBOutlet weak var lunchCollectionView: UICollectionView!
    @IBOutlet weak var dinnerCollectionView: UICollectionView!

    //data struct
    var favouriteFoodIdList = [Int]() //pass id to favourite
    var breakfastFoodList = [TextSearchSuggestionEntity]()
    var lunchFoodList = [TextSearchSuggestionEntity]()
    var dinnerFoodList = [TextSearchSuggestionEntity]()

    //registration flow param
    var isInRegistrationFlow = false

    override func viewDidLoad() {
        breakfastCollectionView.dataSource = self
        breakfastCollectionView.delegate = self
        lunchCollectionView.dataSource = self
        lunchCollectionView.delegate = self
        dinnerCollectionView.dataSource = self
        dinnerCollectionView.delegate = self
        //request popular food data
        getPopularFoodList(mealtime: StringConstants.MealString.breakfast.lowercased())
        getPopularFoodList(mealtime: StringConstants.MealString.lunch.lowercased())
        getPopularFoodList(mealtime: StringConstants.MealString.dinner.lowercased())
        //add done button for the fav food submission
        let rightNavButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(onDonePressed))
        self.navigationItem.rightBarButtonItem = rightNavButton
        //regist nib
        registerNib()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Back Arrow"), style: .plain, target: self, action: #selector(onBackPressed))
        self.navigationItem.leftBarButtonItem?.tintColor = .gray
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(onDonePressed))
        self.navigationItem.rightBarButtonItem?.tintColor = .gray
    }

    func registerNib() {
        let collectionNib = UINib(nibName: "FavouriteFoodCollectionCell", bundle: nil)
        breakfastCollectionView.register(collectionNib, forCellWithReuseIdentifier: "favouriteFoodCollectionCell")
        lunchCollectionView.register(collectionNib, forCellWithReuseIdentifier: "favouriteFoodCollectionCell")
        dinnerCollectionView.register(collectionNib, forCellWithReuseIdentifier: "favouriteFoodCollectionCell")
    }

    func getPopularFoodList(mealtime: String) {
        APIService.instance.getFoodSearchPopularity(mealtime: mealtime, completion: { (textResults) in
           if textResults == nil {
                return
            }
            switch mealtime {
            case StringConstants.MealString.breakfast.lowercased():
                self.breakfastFoodList = textResults!
                self.breakfastCollectionView.reloadData()
            case StringConstants.MealString.lunch.lowercased():
                self.lunchFoodList = textResults!
                self.lunchCollectionView.reloadData()
            case StringConstants.MealString.dinner.lowercased():
                self.dinnerFoodList = textResults!
                self.dinnerCollectionView.reloadData()
            default:break
            }
        }, nextPageCompletion: { (nextLink) in
            //consider next page scenario
        })
    }

    @objc func onBackPressed() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc func onDonePressed() {
        if favouriteFoodIdList.count == 0 {
            AlertMessageHelper.showMessage(targetController: self, title: "", message: "please choose at least one favourite food")
            return
        }
        APIService.instance.setFavouriteFoodList(foodList: favouriteFoodIdList) { (isSuccess) in
            if isSuccess {
                //skip to the registration final view
                if self.isInRegistrationFlow {
                    if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegistrationFinalVC") as? RegistrationFinishViewController {
                        self.navigationController?.pushViewController(dest, animated: true)
                    }
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }

    @IBAction func onSkipBtnPressed(_ sender: Any) {
        //skip to the registration final view
        if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegistrationFinalVC") as? RegistrationFinishViewController {
            self.navigationController?.pushViewController(dest, animated: true)
        }
    }

}

extension PersonalFavouriteFoodViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case breakfastCollectionView: return breakfastFoodList.count
        case lunchCollectionView: return lunchFoodList.count
        case dinnerCollectionView: return dinnerFoodList.count
        default: return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //same cell style
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favouriteFoodCollectionCell", for: indexPath) as? RegistrationFavouriteFoodCell {
            switch collectionView {
            case breakfastCollectionView:cell.setUpCell(entity: breakfastFoodList[indexPath.row])
            case lunchCollectionView:cell.setUpCell(entity: lunchFoodList[indexPath.row])
            case dinnerCollectionView:cell.setUpCell(entity: dinnerFoodList[indexPath.row])
            default:break
            }
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //mark the item that is selected
        var targetList = [TextSearchSuggestionEntity]()
        guard let targetCell = collectionView.cellForItem(at: indexPath) as? RegistrationFavouriteFoodCell else {
            return
        }

        switch collectionView {
        case breakfastCollectionView:
            targetList = breakfastFoodList
        case lunchCollectionView:
            targetList = lunchFoodList
        case dinnerCollectionView:
            targetList = dinnerFoodList
        default:break
        }

        //toggle the selection
        let foodId = targetList[indexPath.row].id

        if let id = favouriteFoodIdList.firstIndex(of: foodId) {
            favouriteFoodIdList.remove(at: id)
            targetCell.toggleFavIcon(isFav: false)
        } else {
            favouriteFoodIdList.append(foodId)
            targetCell.toggleFavIcon(isFav: true)
        }
    }

}
