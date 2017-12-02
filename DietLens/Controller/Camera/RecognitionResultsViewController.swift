//
//  RecognitionResultsViewController.swift
//  DietLens
//
//  Created by next on 14/11/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit

class RecognitionResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var foodSelectionView: UIView!
    @IBOutlet weak var optionListTable: UITableView!
    @IBOutlet weak var caloriePercentage: UILabel!
    @IBOutlet weak var foodName: UITextField!

    @IBOutlet weak var foodCalorie: UILabel!
    @IBOutlet weak var selectDishView: UIView!
    @IBOutlet weak var foodNameOptionTable: UITableView!
    @IBOutlet weak var TFfoodPercentage: UITextField!
    @IBOutlet weak var TFmealType: UITextField!

    @IBOutlet weak var portionStack: UIStackView!
    @IBOutlet weak var ingredientStack: UIStackView!
    var itemPicker: UIPickerView!
    var pickerStatus: String = "" //pickPortion, pickMeal
    var percentagePickerData = ["25%", "50%", "75%", "100%", "150%", "200%", "300%", "400%"]
    var mealPickerData = ["Breakfast", "Lunch", "Dinner"]

    var dateTime: Date? //previous controller should always pass dateTime

    var userFoodImage: UIImage?
    var whichMeal: Meal = .breakfast
    var results: [FoodInfomation]?
    var foodDiary = FoodDiary()
    var recordType: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        foodNameOptionTable.dataSource = self
        foodNameOptionTable.delegate = self
        foodName.delegate = self
        TFfoodPercentage.delegate = self
        TFmealType.delegate = self
        if userFoodImage != nil {
            foodImage.image = userFoodImage
        } else {
            foodImage.image = #imageLiteral(resourceName: "laksa")
        }
        foodImage.contentMode = .scaleAspectFill
        // Do any additional setup after loading the view.
         setUpPickerView()
        self.TFfoodPercentage.inputView = itemPicker
        self.TFmealType.inputView = itemPicker
    }

    func setUpPickerView() {
        itemPicker = UIPickerView()
        itemPicker.dataSource = self
        itemPicker.delegate = self
    }
    // The number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerStatus == "pickPortion"{
            return percentagePickerData.count
        } else if pickerStatus == "pickMeal"{
            return mealPickerData.count
        }
        return 0
    }

    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerStatus == "pickPortion"{
            return percentagePickerData[row]
        } else if pickerStatus == "pickMeal"{
            return mealPickerData[row]
        }
        return ""
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
         if pickerStatus == "pickPortion"{
            TFfoodPercentage.text = percentagePickerData[row]
        } else if pickerStatus == "pickMeal"{
            TFmealType.text = mealPickerData[row]
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        if recordType == "recognition"{
            selectDishView.alpha = 1
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
                foodCalorie.text = String(results![0].calorie) + " kcal"
            }
        } else if recordType == "barcode"{
            selectDishView.alpha = 0
            foodName.text = results![0].foodName
            foodCalorie.text = String(results![0].calorie) + " kcal"
            setFoodInfoIntoDiary(foodInfo: results![0])
        }
    }

//    @IBAction func mealChanged(_ sender: Any) {
//        switch mealOfDay.selectedSegmentIndex {
//        case 0:
//            whichMeal = .breakfast
//             foodDiary.mealType = "breakfast"
//        case 1:
//            whichMeal = .lunch
//             foodDiary.mealType = "lunch"
//        case 2:
//            whichMeal = .dinner
//             foodDiary.mealType = "dinner"
//        default:
//            break
//        }
//    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if results != nil {
            return results!.count
        }
        return 6
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodNameCell") //UITableViewCell()
        cell?.textLabel?.text = "\(results![indexPath.row].foodName)"
        cell?.detailTextLabel?.text = "\(results![indexPath.row].calorie) kcal"
        cell?.imageView?.image = #imageLiteral(resourceName: "food_sample_image")
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseInOut, animations: {
            self.selectDishView.alpha = 0
        }, completion: nil)
//        foodName.isUserInteractionEnabled = false
        foodName.text = results![indexPath.row].foodName
        foodCalorie.text = String(results![indexPath.row].calorie) + " kcal"
        setFoodInfoIntoDiary(foodInfo: results![indexPath.row])
        //set click action on foodName,mealType,eaten percentage
        recordType = "recognition"
        portionStack.isHidden = false
        ingredientStack.isHidden = true
        foodName.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchDown)
        TFmealType.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchDown)
        TFfoodPercentage.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchDown)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }

    @objc func buttonClicked(_ sender: AnyObject?) {
        if sender === TFmealType {
            pickerStatus = "pickMeal"

        } else if sender === TFfoodPercentage {
            pickerStatus = "pickPortion"
        }
        if recordType == "recognition" {
            if sender === foodName {
                UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseInOut, animations: {
                    self.selectDishView.alpha = 1
                }, completion: nil)
            }
        }

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
        print("Ate \(foodName.text ?? "none") for \(whichMeal) on \(dateTime)")
        let diaryFormatter = DateFormatter()
        diaryFormatter.setLocalizedDateFormatFromTemplate("dd MMM yyyy")
        foodDiary.mealTime = diaryFormatter.string(from: dateTime!)
        saveImage(imgData: UIImagePNGRepresentation(foodImage.image!)!, filename: String(Date().timeIntervalSince1970 * 1000)+".png")
        FoodDiaryDBOperation.instance.saveFoodDiary(foodDiary: foodDiary)
        //TODO jump to diaryViewController at another storyboard
        let parent = presentingViewController
        dismiss(animated: false, completion: {
            parent!.dismiss(animated: true, completion: nil)
        })
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

    @IBAction func optionNotInList(_ sender: Any) {
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseInOut, animations: {
            self.selectDishView.alpha = 0
            self.foodName.text = ""
        }, completion: nil)
        recordType = "customized"
        portionStack.isHidden = true
        ingredientStack.isHidden = false
    }

    @IBAction func changeButtonPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseInOut, animations: {
            self.selectDishView.alpha = 1
        }, completion: nil)
    }

    /**
     * Called when 'return' key pressed. return NO to ignore.
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    /**
     * Called when the user click on the view (outside the UITextField).
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == TFfoodPercentage || textField == TFmealType {
            return true
        } else if recordType == "customized" && textField == foodName {
            foodName.text = ""
            foodName.removeTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchDown)
            return true
        } else {
            return false
        }
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
