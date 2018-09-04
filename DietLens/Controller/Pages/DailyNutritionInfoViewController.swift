//
//  DailyNutritionInfoViewController.swift
//  DietLens
//
//  Created by linby on 06/04/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class DailyNutritionInfoViewController: BaseViewController {

    @IBOutlet weak var nutritionTableView: UITableView!
    @IBOutlet weak var tableFooter: UIView!

    var nutritionDict = [String: Double]()
    var displayDict = [Int: (String, Double)]()
    var targetDict = [Int: (String, Double)]()
    //passed value
    var selectedDate = Date()
//    var noInternetAlert: NoInternetDialog?

    override func viewDidLoad() {
        nutritionTableView.delegate = self
        nutritionTableView.dataSource = self
        refresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.sideMenuController?.isLeftViewSwipeGestureEnabled = false
        self.navigationController?.navigationBar.isHidden = true
    }

    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    func refresh() {
        requestNutritionDict(requestDate: selectedDate)
        assembleTargetDict()
//        if !Reachability.isConnectedToNetwork() {
//            //show no Internet connect dialog
//            let storyboard = UIStoryboard(name: "AddFoodScreen", bundle: nil)
//            if let noInternetAlert =  storyboard.instantiateViewController(withIdentifier: "NoInternetVC") as? NoInternetDialog {
//                self.noInternetAlert = noInternetAlert
//                noInternetAlert.delegate = self
//                noInternetAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
//                noInternetAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
//                present(noInternetAlert, animated: true, completion: nil)
//            }
//        } else {
//            requestNutritionDict(requestDate: selectedDate)
//            assembleTargetDict()
//        }
    }

    func assembleDisplayDict(nutritionDict: [String: Double]) {
        displayDict[0] = ("Calorie", nutritionDict["energy"]!)
        displayDict[1] = ("Protein", nutritionDict["protein"]!)
        displayDict[2] = ("Fat", nutritionDict["fat"]!)
        displayDict[3] = ("Carbohydrate", nutritionDict["carbohydrate"]!)
    }

    func assembleTargetDict() {
        let preferences = UserDefaults.standard
        targetDict[0] =  (StringConstants.UIString.calorieUnit, preferences.double(forKey: PreferenceKey.calorieTarget))
        targetDict[1] =  (StringConstants.UIString.diaryIngredientUnit, preferences.double(forKey: PreferenceKey.proteinTarget))
        targetDict[2] =  (StringConstants.UIString.diaryIngredientUnit, preferences.double(forKey: PreferenceKey.fatTarget))
        targetDict[3] =  (StringConstants.UIString.diaryIngredientUnit, preferences.double(forKey: PreferenceKey.carbohydrateTarget))
    }

    func requestNutritionDict(requestDate: Date) {
        APIService.instance.getDailySum(source: self, date: requestDate) { (resultDict) in
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
            let targetSet = targetDict[indexPath.row]
            let progress = kvSet!.1/targetSet!.1
            let unit  = targetSet!.0
            cell.setUpCell(name: (kvSet?.0)!, value: (kvSet?.1)!, progress: Int(progress*100), unit: unit)
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

}
