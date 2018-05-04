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

    var nutritionDict = Dictionary<String, Double>()
    var displayDict = [Int: (String, Double)]()
    //passed value
    var selectedDate = Date()

    override func viewDidLoad() {
        nutritionTableView.delegate = self
        nutritionTableView.dataSource = self
        requestNutritionDict(requestDate: selectedDate)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = "Nutrition Information"
        self.navigationController?.navigationBar.backItem?.title = ""
        self.navigationController?.navigationBar.backItem?.titleView?.tintColor = UIColor.white
        self.navigationController?.navigationBar.backgroundColor = UIColor.red
    }

    @IBAction func onBackPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    func assembleDisplayDict(nutritionDict: Dictionary<String, Double>) {
        displayDict[0] = ("Calorie", nutritionDict["energy"]!)
        displayDict[1] = ("Protein", nutritionDict["protein"]!)
        displayDict[2] = ("Fat", nutritionDict["fat"]!)
        displayDict[3] = ("Carbohydrate", nutritionDict["carbohydrate"]!)
    }

    func requestNutritionDict(requestDate: Date) {
        APIService.instance.getDailySum(date: requestDate) { (resultDict) in
            if resultDict.count == 0 {
                return
            }
            self.assembleDisplayDict(nutritionDict: resultDict)
            self.nutritionTableView.reloadData()
        }
    }

}

extension DailyNutritionInfoViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.displayDict.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "dailyNutritionTableCell") as? DailyNutritionTableCell {
            let kvSet = displayDict[indexPath.row]
            cell.setUpCell(name: (kvSet?.0)!, value: String((kvSet?.1)!), progress: 50)
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

}
