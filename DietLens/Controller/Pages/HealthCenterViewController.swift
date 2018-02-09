//
//  HealthCenterController.swift
//  DietLens
//
//  Created by linby on 16/01/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
class HealthCenterViewController: UIViewController {

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var healthCenterTable: UITableView!

    var selectedDeviceType = ""
    var selectedDeviceUnit = ""

    override func viewDidLoad() {
        healthCenterTable.delegate = self
        healthCenterTable.dataSource = self
    }

    override func viewDidAppear(_ animated: Bool) {
        healthCenterTable.reloadData()
    }

    @IBAction func onBackPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
extension HealthCenterViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //TODO search last record from the database
        let latestWeight: HealthRecord = HealthCenterDBOperation.instance.getLatestResultOfRecord(recordType: "Weight")
        let latestBloodGlucose: HealthRecord = HealthCenterDBOperation.instance.getLatestResultOfRecord(recordType: "BloodGlucose")
        if let cell = tableView.dequeueReusableCell(withIdentifier: "healthCenterToolCell") as? HealthToolCell {
            switch indexPath.row {
                case (0):
                    cell.setupCell(icon: #imageLiteral(resourceName: "weightDevice"), title: "WEIGHT", lastRecord: String(latestWeight.value)+latestWeight.unit)
                    break
                case (1):
                     cell.setupCell(icon: #imageLiteral(resourceName: "bloodGlucoseDevice"), title: "BLOOD GLUCOSE", lastRecord: String(latestBloodGlucose.value)+latestBloodGlucose.unit)
                    break
                default:
                    break
            }
            return cell
        } else {
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case (0):
            selectedDeviceType = "Weight"
            selectedDeviceUnit = "KG"
            break
        case (1):
            selectedDeviceType = "BloodGlucose"
            selectedDeviceUnit = "mmol/L"
            break
        default:
            break
        }
        performSegue(withIdentifier: "toHealthCenterDetail", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? DeviceRecordDetailViewController {
            dest.deviceType = selectedDeviceType
            dest.unit = selectedDeviceUnit
        }
    }

}
