//
//  RecognitionResultViewController.swift
//  DietLens
//
//  Created by linby on 10/04/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
class RecognitionResultViewController:UIViewController {
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var foodCategory: UICollectionView!
    @IBOutlet weak var foodOptionTable: UITableView!
    @IBOutlet weak var textSearchFloatingBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    
    //dataSource
    var foodCategoryList = [String]()
    var foodItemList = [FoodInfomation]()
    
    override func viewDidLoad() {
        
    }
    
    
}

extension RecognitionResultViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodItemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}

extension RecognitionResultViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return foodCategoryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    
}
