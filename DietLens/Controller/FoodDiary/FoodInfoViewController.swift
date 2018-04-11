//
//  FoodInfoViewController.swift
//  DietLens
//
//  Created by linby on 10/04/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
class FoodInfoViewController: UIViewController{
    @IBOutlet weak var foodSampleImage:UIImageView!
    @IBOutlet weak var calorieValueLabel:UILabel!
    @IBOutlet weak var proteinValueLable:UILabel!
    @IBOutlet weak var fatValueLabel:UILabel!
    @IBOutlet weak var carbohydrateValueLabel:UILabel!
    @IBOutlet weak var foodName:UILabel!
    @IBOutlet weak var quantityValue:UILabel!
    @IBOutlet weak var unitValue:UILabel!
    
    //data source
    var addedFood = FoodInfomation()
    var portionUnit = PortionModel()
    var quantity:Double = 1.0
    
    override func viewDidLoad() {
        
    }
    
    func flipToShowNutrition(){
        
    }
    
}
