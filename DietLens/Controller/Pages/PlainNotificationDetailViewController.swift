//
//  SingleNotificationViewController.swift
//  DietLens
//
//  Created by next on 29/11/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit

class PlainNotificationDetailViewController: UIViewController {

    @IBOutlet weak var notificationTitle: UILabel!
    @IBOutlet weak var dateTime: UILabel!
    @IBOutlet weak var body: UITextView!
    var notification = NotificationModel()

    fileprivate let formatter: DateFormatter = {
        let formatter = DateFormatter()
        //dateFormatter.locale = Locale(identifier: "en_GB")
        formatter.setLocalizedDateFormatFromTemplate("dd MMM HH:mm")
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        notificationTitle.text = notification.title
        dateTime.text = formatter.string(from: notification.dateReceived)
        body.text = notification.content
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
