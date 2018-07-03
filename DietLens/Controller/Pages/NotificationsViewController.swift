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
    //notification data & pagination
    var notificationSectionList = [NotificationSection]()
    var currentLink = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        notificationTable.delegate = self
        notificationTable.dataSource = self
//        sampleData()
        self.clearButton.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(refresh(_:)), name: .didReceiveNotification, object: nil)
        // Do any additional setup after loading the view.
    }

    @objc func refresh(_ notification: NSNotification) {
        getNotifcationData()
    }

    func getNotifcationData() {
        APIService.instance.getNotificationList(completion: { (notificationList) in
            self.notificationSectionList.removeAll()
            if notificationList != nil {
                if notificationList?.count == 0 {
                    self.clearButton.isHidden = true
                    self.emptyViewIcon.isHidden = false
                    self.emptyViewLabel.isHidden = false
                } else {
                    self.clearButton.isHidden = false
                    self.emptyViewIcon.isHidden = true
                    self.emptyViewLabel.isHidden = true
                }
                for notification in notificationList! {
                    var flag = true
                    for (index, section) in self.notificationSectionList.enumerated() where DateUtil.day3MDateToString(date: section.date) == DateUtil.day3MDateToString(date: notification.createTime) {
                        self.notificationSectionList[index].notificationList.append(notification)
                        flag = false
                    }
                    if flag {
                        var notificaitonSection = NotificationSection()
                        notificaitonSection.date = notification.createTime
                        notificaitonSection.notificationList.append(notification)
                        self.notificationSectionList.append(notificaitonSection)
                    }
                }
                self.notificationTable.reloadData()
            }
        }) { (nextLink) in
            self.currentLink = nextLink
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        //set status bar appearance
        UIApplication.shared.statusBarStyle = .default
        //reload data
        getNotifcationData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func clearNotificationPressed(_ sender: Any) {
        if notificationSectionList.count == 0 {
            return
        }
        AlertMessageHelper.showOkCancelDialog(targetController: self, title: "", message: "Delete All the notifcations?", postiveText: "confirm", negativeText: "cancel") { (flag) in
            if flag {
                print("clear notifications!")
                APIService.instance.deleteAllNotification { (isSuccess) in
                    if isSuccess! {
                        self.notificationSectionList.removeAll()
                        self.notificationTable.reloadData()
                    }
                }
            }
        }
    }

    func checkEmpty() {
        if notificationSectionList.count == 0 {
            emptyViewIcon.alpha = 1
            emptyViewLabel.alpha = 1
        } else {
            emptyViewIcon.alpha = 0
            emptyViewLabel.alpha = 0
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = notificationTable.indexPathForSelectedRow {
            //print("selected: \(indexPath.row)")
            notificationTable.deselectRow(at: indexPath, animated: true)
            let notificationData = notificationSectionList[indexPath.section].notificationList[indexPath.row]
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
        let dateText = DateUtil.day3MDateToString(date: notificationSectionList[section].date)
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
            cell.setupCell(notificationData: notificationSectionList[indexPath.section].notificationList[indexPath.row])
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
            APIService.instance.deleteNotification(notificationId: notificationSectionList[indexPath.section].notificationList[indexPath.row].id, completion: { (isSuccess) in
                if isSuccess! {
                    self.notificationSectionList[indexPath.section].notificationList.remove(at: indexPath.row)
                    self.notificationTable.reloadData()
                }
            })
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        checkEmpty()
        return notificationSectionList[section].notificationList.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return notificationSectionList.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "presentNotifcationDetail", sender: self)
        if notificationSectionList[indexPath.section].notificationList[indexPath.row].read == false {
            APIService.instance.didReceiveNotifcation(notificationId: notificationSectionList[indexPath.section].notificationList[indexPath.row].id) { (isSuccess) in
                if isSuccess! {
                    self.notificationSectionList[indexPath.section].notificationList[indexPath.row].read = true
                }
            }
        }
    }
}
