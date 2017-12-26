//
//  StepCounterViewController.swift
//  DietLens
//
//  Created by linby on 25/12/2017.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit
class StepCounterViewController: UIViewController {

    @IBOutlet weak var standardLabel: UILabel!

    @IBOutlet weak var stepCounterTable: UITableView!

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

            print("HealthKit Successfully Authorized.")
        }

    }

}

extension StepCounterViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

}
