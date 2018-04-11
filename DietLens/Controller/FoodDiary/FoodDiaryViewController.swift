//
//  FoodDiaryViewController.swift
//  DietLens
//
//  Created by linby on 10/04/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class FoodDiaryViewController: UIViewController{
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var mealTypeCollection: UICollectionView!
    @IBOutlet weak var foodTableView: UITableView!
    
    @IBOutlet weak var calorieValueLabel:UILabel!
    @IBOutlet weak var proteinValueLable:UILabel!
    @IBOutlet weak var fatValueLabel:UILabel!
    @IBOutlet weak var carbohydrateLabel:UILabel!
    
    //dataSource
    var foodItemList = [FoodInfomation]()
    var accumulateCalorie:Double = 0.0
    var accumulateCabohydrate:Double = 0.0
    var accumulateProtein:Double = 0.0
    var accumulateFat:Double = 0.0
    var mealType:Meal = .breakfast
//    var mealTextList = []
    
    
    override func viewDidLoad() {
        
    }
}
