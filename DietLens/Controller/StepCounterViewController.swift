//
//  StepCounterViewController.swift
//  DietLens
//
//  Created by linby on 25/12/2017.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit
import HealthKit
import SwiftyJSON
class StepCounterViewController: BaseViewController {

    @IBOutlet weak var standardLabel: UILabel!

    @IBOutlet weak var stepCounterTable: UITableView!

    @IBOutlet weak var emptyView: UITextView!

    var stepsList = [StepEntity]()

    override func viewDidLoad() {
        stepCounterTable.delegate = self
        stepCounterTable.dataSource = self
        emptyView.delegate = self
        emptyView.isHidden = true
        requestAuthFromHealthKit()
        //set observer refresh the stepList when come back from healthCenter or other app
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
    }

    @objc func willEnterForeground() {
        requestStepData()
    }

//    @IBAction func onBackPressed(_ sender: Any) {
//        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil)
//        dismiss(animated: true, completion: nil)
//    }

    func requestAuthFromHealthKit() {
        if HKHealthStore.isHealthDataAvailable() {
            HealthKitSetupAssistant.authorizeHealthKit { (authorized, error) in

                guard authorized else {

                    let baseMessage = "HealthKit Authorization Failed"
                    self.emptyView.isHidden = false
                    if let error = error {
                        print("\(baseMessage). Reason: \(error.localizedDescription)")
                    } else {
                        print(baseMessage)
                    }
                    return
                }
                self.requestStepData()
            }
        }
    }

    func getMaxValue() -> Double {
        var max: Double = 0.0
        for stepEntity in stepsList where stepEntity.stepValue > max {
            max = stepEntity.stepValue
        }
        return max
    }

    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    func requestStepData() {
        HKHealthStore().getWeeklyStepsCountList(anyDayOfTheWeek: Date()) { (steps, _) in
            self.stepsList = steps
            //reverse sequence to let latest setp date rank first
            self.stepsList.reverse()
            DispatchQueue.main.async {
                if self.stepsList.count == 0 {
                    self.emptyView.isHidden = false
                } else {
                    self.emptyView.isHidden = true
                }
                self.stepCounterTable.reloadData()
                self.uploadStepData()
            }
        }
    }

    func uploadStepData() {
        var stepArray = [[String: Any]]()
        for index in 0..<stepsList.count {
            var step: [String: Any] = [:]
            let dateStr = DateUtil.normalDateToString(date: stepsList[index].date!)
            step["exercise_datetime"] = dateStr
            step["exercise_amount"] = String(stepsList[index].stepValue)
            stepArray.append(step)
        }
        let params = ["steps": stepArray]
        let preferences = UserDefaults.standard
        let key = "userId"
        let userId = preferences.string(forKey: key)
        APIService.instance.uploadStepData(userId: userId!, params: params) { (isSuccess) in
            if !isSuccess {
                print("upload step data failed")
            }
        }
    }

}

extension StepCounterViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stepsList.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //
        if let cell = tableView.dequeueReusableCell(withIdentifier: "stepCounterCell") as? StepCounterCell {
            cell.setupCell(stepEntity: stepsList[indexPath.row], maxValue: self.getMaxValue())
            return cell
        } else {
            return UITableViewCell()
        }
    }

}

extension StepCounterViewController: UITextViewDelegate {

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        UIApplication.shared.open(URL(string: "x-apple-health://")!)
        return false
    }

}
