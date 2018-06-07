//
//  AboutViewController.swift
//  DietLens
//
//  Created by next on 6/11/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var sideMenuButton: UIBarButtonItem!

    @IBOutlet weak var appImageIcon: UIImageView!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var buildNumberLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
        versionLabel.text = "Dietlens  V " + version
        buildNumberLabel.text = "Build " + buildNumber
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onBackPressed(_ sender: UIButton) {
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
