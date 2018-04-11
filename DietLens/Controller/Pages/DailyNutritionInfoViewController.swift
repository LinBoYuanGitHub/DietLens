//
//  DailyNutritionInfoViewController.swift
//  DietLens
//
//  Created by linby on 06/04/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class DailyNutritionInfoViewController: UIViewController {

    @IBOutlet weak var nutritionTableView: UITableView!
    @IBOutlet weak var tableFooter: UIView!

    var nutritionList = [String]()

    override func viewDidLoad() {
        self.navigationController?.navigationBar.topItem?.title = "Nutrition Information"
        self.navigationController?.navigationBar.backItem?.title = ""
        self.navigationController?.navigationBar.backItem?.titleView?.tintColor = UIColor.white
        self.navigationController?.navigationBar.backgroundColor = UIColor.red
    }

}

extension DailyNutritionInfoViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nutritionList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

}
