//
//  SettingViewController.swift
//  DietLens
//
//  Created by next on 6/11/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit
import PBRevealViewController

class SettingViewController: UIViewController {

    @IBOutlet weak var sideMenuButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()

        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedStringKey.font: UIFont(name: "SignPainterHouseScript", size: 32)!, NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.6347548905, green: 0.6361853982, blue: 0.6580147525, alpha: 1)]
        sideMenuButton.target = self.revealViewController()
        sideMenuButton.action = #selector(PBRevealViewController.revealLeftView)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
