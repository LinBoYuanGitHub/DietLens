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
    @IBOutlet weak var foodNameField: UITextInput!
    @IBOutlet weak var buttonB: UIButton!
    @IBOutlet weak var buttonL: UIButton!
    @IBOutlet weak var buttonD: UIButton!
    @IBOutlet weak var foodSelectionView: UIView!
    @IBOutlet weak var optionListTable: UITableView!

    var userFoodImage = UIImage()
    var whichMeal: Meal = .breakfast
    var results: [FoodInfomation]?

    override func viewDidLoad() {
        super.viewDidLoad()
        buttonB.addTarget(self, action: #selector(mealButtonPressed), for: .touchUpInside)
        buttonL.addTarget(self, action: #selector(mealButtonPressed), for: .touchUpInside)
        buttonD.addTarget(self, action: #selector(mealButtonPressed), for: .touchUpInside)
        foodSelectionView.alpha = 1
        foodImage.image = userFoodImage
        // Do any additional setup after loading the view.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if results != nil {
            return results!.count
        }
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "foodNameCell")
        cell?.textLabel?.text = "\(indexPath.row). \(results![indexPath.row].foodName)"
        cell?.textLabel?.text = ""
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseInOut, animations: {
            self.foodSelectionView.alpha = 0
        }, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func doneButtonPressed(_ sender: Any) {
        print("Ate \(foodNameField) for \(whichMeal)")
        dismiss(animated: true, completion: nil)
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @objc func mealButtonPressed(sender: UIButton!) {
        let btnsendtag: UIButton = sender
        if btnsendtag.tag == 0 {
            whichMeal = .breakfast
        } else if btnsendtag.tag == 1 {
            whichMeal = .lunch
        } else {
            whichMeal = .dinner
        }
    }
    @IBAction func optionNotInList(_ sender: Any) {

    }

    @IBAction func changeButtonPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseInOut, animations: {
            self.foodSelectionView.alpha = 1
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
