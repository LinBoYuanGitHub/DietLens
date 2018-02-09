//
//  NotificationsViewController.swift
//  DietLens
//
//  Created by next on 29/11/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var notificationTable: UITableView!

    @IBOutlet weak var emptyViewIcon: UIImageView!
    @IBOutlet weak var emptyViewLabel: UILabel!

    var listOfNotifications = [NotificationModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationTable.delegate = self
        notificationTable.dataSource = self
//        sampleData()
        getNotifcationData()
        NotificationCenter.default.addObserver(self, selector: #selector(refresh(_:)), name: .didReceiveNotification, object: nil)
        // Do any additional setup after loading the view.
    }

    @objc func refresh(_ notification: NSNotification) {
        if let message = notification.userInfo?["message"] as? String {
            listOfNotifications.insert(NotificationModel.init(id: "A2", body: message, title: "Reminder", read: false, dateReceived: Date()), at: 0)
            let range = NSRange(location: 0, length: 1)
            let sections = NSIndexSet(indexesIn: range)
            notificationTable.reloadSections(sections as IndexSet, with: UITableViewRowAnimation.automatic)
        }
    }

    func getNotifcationData() {
        let preferences = UserDefaults.standard
        let key = "userId"
        let userId = preferences.string(forKey: key)
        APIService.instance.getNotificationList(userId: userId!) { (notificationList) in
            self.listOfNotifications.removeAll()
            if notificationList != nil {
                self.listOfNotifications = notificationList!
                self.notificationTable.reloadData()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        notificationTable.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell") as? NotificationTableCell {
            cell.setupCell(notificationData: listOfNotifications[indexPath.row])
            return cell
        }
        return UITableViewCell()
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
        performSegue(withIdentifier: "showNotificationDetailPage", sender: self)
        if listOfNotifications[indexPath.row].read == false {
            APIService.instance.didReceiveNotifcation(notificationId: listOfNotifications[indexPath.row].id) { (isSuccess) in
                if isSuccess! {
                    self.listOfNotifications[indexPath.row].read = true
                }
            }
        }
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
                let preferences = UserDefaults.standard
                let key = "userId"
                let userId = preferences.string(forKey: key)
                APIService.instance.deleteAllNotification(userId: userId!) { (isSuccess) in
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
        listOfNotifications.append(NotificationModel.init(id: "A1", body: "It's past lunch tine. Don't forget to eat!", title: "Reminder", read: false, dateReceived: Date()))
        listOfNotifications.append(NotificationModel.init(id: "B2", body: "Tomorrow at 3pm with Dr Lim @ NUH", title: "Appointment tomorrow", read: true, dateReceived: Date()))
        listOfNotifications.append(NotificationModel.init(id: "B3", body: "Not suppose to show. Tomorrow at 3pm with Dr Lim @ NUH", title: "Appointment tomorrow", read: true, dateReceived: Date()))
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = notificationTable.indexPathForSelectedRow {
            //print("selected: \(indexPath.row)")
            notificationTable.deselectRow(at: indexPath, animated: true)
            let notificationData = listOfNotifications[indexPath.row]
            if let dest = segue.destination as? SingleNotificationViewController {
                dest.notification = notificationData
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
