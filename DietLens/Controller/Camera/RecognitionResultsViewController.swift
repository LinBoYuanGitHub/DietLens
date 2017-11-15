//
//  RecognitionResultsViewController.swift
//  DietLens
//
//  Created by next on 14/11/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit

class RecognitionResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var foodSelectionView: UIView!
    @IBOutlet weak var optionListTable: UITableView!
    @IBOutlet weak var mealOfDay: UISegmentedControl!
    @IBOutlet weak var foodName: UITextField!

    @IBOutlet weak var selectDishView: UIView!
    @IBOutlet weak var foodNameOptionTable: UITableView!
    @IBOutlet weak var dateTime: UIDatePicker!
    var userFoodImage: UIImage?
    var whichMeal: Meal = .breakfast
    var results: [FoodInfomation]?
    var foodDiary = FoodDiary()

    override func viewDidLoad() {
        super.viewDidLoad()
        foodNameOptionTable.dataSource = self
        foodNameOptionTable.delegate = self
        selectDishView.alpha = 1
        if userFoodImage != nil {
            foodImage.image = userFoodImage
        } else {
            foodImage.image = #imageLiteral(resourceName: "laksa")
        }
        if results == nil || results?.count == 0 {
            results = [FoodInfomation]()
            var f1 = FoodInfomation()
            f1.foodName = "laksa"
            results!.append(f1)
            f1.foodName = "mee goreng"
            results!.append(f1)
            f1.foodName = "laksa goreng"
            results!.append(f1)
            f1.foodName = "nasi goreng"
            results!.append(f1)
            f1.foodName = "beehoon goreng"
            results!.append(f1)
            f1.foodName = "kway tiao goreng"
            results!.append(f1)
        } else {
            setFoodInfoIntoDiary(foodInfo: results![0])
        }
        foodImage.contentMode = .scaleAspectFill
        // Do any additional setup after loading the view.
    }

    @IBAction func mealChanged(_ sender: Any) {
        switch mealOfDay.selectedSegmentIndex {
        case 0:
            whichMeal = .breakfast
        case 1:
            whichMeal = .lunch
        case 2:
            whichMeal = .dinner
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if results != nil {
            return results!.count
        }
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell() //tableView.dequeueReusableCell(withIdentifier: "foodNameCell")
        cell.textLabel?.text = "\(indexPath.row+1). \(results![indexPath.row].foodName)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseInOut, animations: {
            self.selectDishView.alpha = 0
        }, completion: nil)
        foodName.text = results![indexPath.row].foodName
        setFoodInfoIntoDiary(foodInfo: results![indexPath.row])

    }

    func setFoodInfoIntoDiary(foodInfo: FoodInfomation) {
        foodDiary.foodId = foodInfo.foodId
        foodDiary.foodName = foodInfo.foodName
        foodDiary.calorie = Double(foodInfo.calorie)
        foodDiary.carbohydrate = foodInfo.carbohydrate
        foodDiary.protein = foodInfo.protein
        foodDiary.fat = foodInfo.fat
        //        foodDiary?.recordType
        //        foodDiary?.imagePath
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func doneButtonPressed(_ sender: Any) {
        print("Ate \(foodName.text ?? "none") for \(whichMeal) on \(dateTime.date)")
        let diaryFormatter = DateFormatter()
        diaryFormatter.setLocalizedDateFormatFromTemplate("dd MMM yyyy")
        foodDiary.mealTime = diaryFormatter.string(from: dateTime.date)
        saveImage(imgData: UIImagePNGRepresentation(foodImage.image!)!, filename: String(Date().timeIntervalSince1970 * 1000)+".png")
        FoodDiaryDBOperation.instance.saveFoodDiary(foodDiary: foodDiary)
        dismiss(animated: true, completion: nil)
    }

    func saveImage(imgData: Data, filename: String) {
        var documentsUrl: URL {
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
        let writePath = documentsUrl.appendingPathComponent(filename)
        try? imgData.write(to: writePath, options: .atomic)
        foodDiary.imagePath = filename
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @objc func mealButtonPressed(sender: UIButton!) {
        let btnsendtag: UIButton = sender
        if btnsendtag.tag == 0 {
            whichMeal = .breakfast
            foodDiary.mealType = "breakfast"
        } else if btnsendtag.tag == 1 {
            whichMeal = .lunch
            foodDiary.mealType = "lunch"
        } else {
            whichMeal = .dinner
            foodDiary.mealType = "dinner"
        }
    }
    @IBAction func optionNotInList(_ sender: Any) {
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseInOut, animations: {
            self.selectDishView.alpha = 0
        }, completion: nil)
    }

    @IBAction func changeButtonPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseInOut, animations: {
            self.selectDishView.alpha = 1
        }, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
