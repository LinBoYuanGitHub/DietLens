//
//  DeviceRecordDetailViewController.swift
//  DietLens
//
//  Created by linby on 16/01/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class DeviceRecordDetailViewController: UIViewController {
    @IBOutlet weak var inputLabel: UILabel!
    @IBOutlet weak var historyLabel: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var addBtn: UIButton!

    @IBOutlet weak var historyTable: UITableView!

    var historyList = [HealthRecord]()
    var deviceType = ""
    var unit = ""

    override func viewDidLoad() {
        inputLabel.text = "Please Input Current " + deviceType
        historyLabel.text =  deviceType + " History"
        historyTable.delegate = self
        historyTable.dataSource = self
        getHistoryRecord()
        configKeyBoard()
    }

    func configKeyBoard() {
        inputTextField.keyboardType = UIKeyboardType.decimalPad
        inputTextField.delegate = self
    }

    @IBAction func onBackPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func addCurrentWeight(_ sender: Any) {
        if (inputTextField.text?.isEmpty)! {
            AlertMessageHelper.showMessage(targetController: self, title: "", message: "Please input a number of your \(deviceType)")
            return
        }
        let healthRecord = HealthRecord()
        healthRecord.date = Date()
        healthRecord.type = deviceType
        healthRecord.value = Float(inputTextField.text!)!
        healthRecord.unit = unit
        let preferences = UserDefaults.standard
        let key = "userId"
        let userId = preferences.string(forKey: key)
        let date = DateUtil.templateDateToString(date: Date())
        let dateStr = date.split(separator: ",")[0]
        let timeStr = date.split(separator: ",")[1]
        let dateStrArr = dateStr.split(separator: "/")
        let finalDate = dateStrArr[2] + "-" + dateStrArr[1] + "-" + dateStrArr[0] + timeStr
        APIService.instance.uploadHealthCenterData(userId: userId!, title: deviceType, content: deviceType, unit: unit, amount: String(healthRecord.value), datetime: finalDate) { (isSuccess) in
            if isSuccess {
                HealthCenterDBOperation.instance.savehealthRecord(healthRecord: healthRecord)
                self.getHistoryRecord()
                self.inputTextField.text = ""
            } else {
                AlertMessageHelper.showMessage(targetController: self, title: "", message: "upload data failed")
            }
        }
    }

    func getHistoryRecord() {
        historyList = HealthCenterDBOperation.instance.getTopHealthRecord(recordType: deviceType)
        historyTable.reloadData()
    }

}

extension DeviceRecordDetailViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        inputTextField.resignFirstResponder()
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}

extension DeviceRecordDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyList.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "historyDeviceDataCell") as? HealthDeviceDataCell {
            let dateStr = DateUtil.day3MDateToString(date: historyList[indexPath.row].date)
            cell.setupCell(value: String(historyList[indexPath.row].value), unit: historyList[indexPath.row].unit, dateStr: dateStr)
            return cell
        } else {
            return UITableViewCell()
        }
    }

}
