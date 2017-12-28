//
//  StepCounterViewController.swift
//  DietLens
//
//  Created by linby on 25/12/2017.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit
import HealthKit
class StepCounterViewController: UIViewController {

    @IBOutlet weak var standardLabel: UILabel!

    @IBOutlet weak var stepCounterTable: UITableView!

    var stepsList = [StepEntity]()

    override func viewDidLoad() {
        stepCounterTable.delegate = self
        stepCounterTable.dataSource = self
        requestAuthFromHealthKit()
    }

    @IBAction func onBackPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    func requestAuthFromHealthKit() {
        HealthKitSetupAssistant.authorizeHealthKit { (authorized, error) in

            guard authorized else {

                let baseMessage = "HealthKit Authorization Failed"

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

    func getMaxValue() -> Double {
        var max: Double = 0.0
        for stepEntity in stepsList {
            if stepEntity.stepValue > max {
                max = stepEntity.stepValue
            }
        }
        return max
    }

    func requestStepData() {
        HKHealthStore().getWeeklyStepsCountList(anyDayOfTheWeek: Date()) { (steps, _) in
            self.stepsList = steps
            DispatchQueue.main.async {
                 self.stepCounterTable.reloadData()
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
