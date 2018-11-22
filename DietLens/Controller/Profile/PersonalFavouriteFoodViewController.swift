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
    var favouriteFoodIdList = [String]() //pass id to favourite
    var breakfastFoodList = [TextSearchSuggestionEntity]()
    var lunchFoodList = [TextSearchSuggestionEntity]()
    var dinnerFoodList = [TextSearchSuggestionEntity]()

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
    }
    
    func getPopularFoodList(mealtime:String){
        APIService.instance.getFoodSearchPopularity(mealtime: mealtime, completion: { (textResults) in
            if textResults == nil {
                return
            }
//            switch mealtime {
//            case StringConstants.MealString.breakfast:
//                breakfastFoodList = textResults
//                breakfastCollectionView.reloadData()
//            case StringConstants.MealString.lunch:
//                breakfastFoodList = textResults
//            case StringConstants.MealString.dinner:
//                breakfastFoodList = textResults
//            default:break
//            }
            
        }, nextPageCompletion: { (nextLink) in
            //consider next page scenario
        })
    }

    @IBAction func onSkipBtnPressed(_ sender: Any) {
        
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
        
    }
    
    
}
