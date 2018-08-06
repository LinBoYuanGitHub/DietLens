//
//  SingleNotificationViewController.swift
//  DietLens
//
//  Created by next on 29/11/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit

class SingleNotificationViewController: UIViewController {

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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
