//
//  NotificationsViewController.swift
//  DietLens
//
//  Created by next on 29/11/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController {

    @IBOutlet weak var notificationTable: UITableView!

    @IBOutlet weak var emptyViewIcon: UIImageView!
    @IBOutlet weak var emptyViewLabel: UILabel!

    @IBOutlet weak var clearButton: UIButton!

    var listOfNotifications = [NotificationModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationTable.delegate = self
        notificationTable.dataSource = self
//        sampleData()
        getNotifcationData()
        self.clearButton.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(refresh(_:)), name: .didReceiveNotification, object: nil)
        // Do any additional setup after loading the view.
    }

    @objc func refresh(_ notification: NSNotification) {
        getNotifcationData()
//        if (notification.userInfo?["message"] as? String) != nil {
//            listOfNotifications.append(NotificationModel.init(id: "A1", title: "Reminder", body: "It's past lunch tine. Don't forget to eat!", content: "It's past lunch tine. Don't forget to eat!", prompt: "", imgUrl: "", responseType: "1", responseOptions: [], read: true, dateReceived: Date()))
//            let range = NSRange(location: 0, length: 1)
//            let sections = NSIndexSet(indexesIn: range)
//            notificationTable.reloadSections(sections as IndexSet, with: UITableViewRowAnimation.automatic)
//        }
    }

    func getNotifcationData() {
        APIService.instance.getNotificationList { (notificationList) in
            self.listOfNotifications.removeAll()
            if notificationList != nil {
                if notificationList?.count == 0 {
                    self.clearButton.isHidden = true
                } else {
                    self.clearButton.isHidden = false
                }
                self.listOfNotifications = notificationList!
                self.notificationTable.reloadData()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        //set status bar appearance
        UIApplication.shared.statusBarStyle = .default
        //reload data
        notificationTable.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func clearNotificationPressed(_ sender: Any) {
        if listOfNotifications.count == 0 {
            return
        }
        AlertMessageHelper.showOkCancelDialog(targetController: self, title: "", message: "Delete All the notifcations?", postiveText: "confirm", negativeText: "cancel") { (flag) in
            if flag {
                print("clear notifications!")
                APIService.instance.deleteAllNotification { (isSuccess) in
                    if isSuccess! {
                        self.listOfNotifications.removeAll()
                        self.notificationTable.reloadData()
                    }
                }
            }
        }
    }

    func checkEmpty() {
        if listOfNotifications.count == 0 {
            emptyViewIcon.alpha = 1
            emptyViewLabel.alpha = 1
        } else {
            emptyViewIcon.alpha = 0
            emptyViewLabel.alpha = 0
        }
    }

    func sampleData() {
        listOfNotifications.append(NotificationModel.init(id: "A1", title: "Reminder", body: "It's past lunch tine. Don't forget to eat!", content: "It's past lunch tine. Don't forget to eat!", prompt: "", imgUrl: "", responseType: "1", responseOptions: [], read: false, dateReceived: Date()))
        listOfNotifications.append(NotificationModel.init(id: "B2", title: "Appointment tomorrow", body: "Tomorrow at 3pm with Dr Lim @ NUH", content: "Tomorrow at 3pm with Dr Lim @ NUH", prompt: "", imgUrl: "", responseType: "2", responseOptions: [], read: true, dateReceived: Date()))
        listOfNotifications.append(NotificationModel.init(id: "B3", title: "Appointment tomorrow", body: "Not suppose to show. Tomorrow at 3pm with Dr Lim @ NUH", content: "Not suppose to show. Tomorrow at 3pm with Dr Lim @ NUH", prompt: "", imgUrl: "", responseType: "3", responseOptions: [], read: false, dateReceived: Date()))
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = notificationTable.indexPathForSelectedRow {
            //print("selected: \(indexPath.row)")
            notificationTable.deselectRow(at: indexPath, animated: true)
            let notificationData = listOfNotifications[indexPath.row]
            if let dest = segue.destination as? NotificationDetailViewController {
                dest.notificationModel = notificationData
            }
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

extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 33))
        let titleLabel = UILabel(frame: CGRect(x: 16, y: 8, width: 42, height: 17))
        let dateText = "May 23"
        let titleText = NSMutableAttributedString.init(string: dateText)
        titleText.setAttributes([NSAttributedStringKey.font: UIFont(name: "PingFangSC-Light", size: 12.0), kCTForegroundColorAttributeName as NSAttributedStringKey: UIColor.gray], range: NSRange(location: 0, length: dateText.count))
        titleLabel.attributedText = titleText
        headerView.addSubview(titleLabel)
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 33
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell") as? NotificationTableCell {
            cell.setupCell(notificationData: listOfNotifications[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            APIService.instance.deleteNotification(notificationId: listOfNotifications[indexPath.row].id, completion: { (isSuccess) in
                if isSuccess! {
                    self.listOfNotifications.remove(at: indexPath.row)
                    self.notificationTable.reloadData()
                }
            })
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        checkEmpty()
        return listOfNotifications.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "presentNotifcationDetail", sender: self)
        if listOfNotifications[indexPath.row].read == false {
            APIService.instance.didReceiveNotifcation(notificationId: listOfNotifications[indexPath.row].id) { (isSuccess) in
                if isSuccess! {
                    self.listOfNotifications[indexPath.row].read = true
                }
            }
        }
    }
}
