//
//  SideMenuViewController.swift
//  DietLens
//
//  Created by next on 31/10/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit
import PBRevealViewController

class SideMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PBRevealViewControllerDelegate {

    @IBOutlet weak var sideMenuTable: UITableView!

//    let labels: [String] = ["Home", "Food Diary", "Report", "Articles", "Steps Counter", "Browser"]
//    let iconNames: [String] = ["checkmark", "Report", "ReportIcon", "ArticleIcon", "Steps", "browser"]
//    let storyboardIDs: [String] = ["DietLens", "calendarViewController", "ReportVC", "ArticleVC", "StepCounterVC", "BrowserPage"]

    let labels: [String] = ["Home", "Food Diary", "Report", "Articles", "Steps Counter"]
    let iconNames: [String] = ["home", "Report", "ReportIcon", "ArticleIcon", "Steps"]
    let storyboardIDs: [String] = ["DietLens", "calendarViewController", "ReportVC", "ArticleVC", "StepCounterVC"]

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenuTable.delegate = self
        sideMenuTable.dataSource = self

        self.revealViewController()!.delegate = self
        self.revealViewController()!.toggleAnimationType = .crossDissolve
        self.revealViewController()!.leftViewShadowOpacity = 0
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        for subview in sideMenuTable.subviews where subview is UIVisualEffectView {
            subview.alpha = 0
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "menuButtonCell") as? SideMenuCell {
            cell.setupSideMenuCell(buttonName: labels[indexPath.row], iconImage: UIImage(named: iconNames[indexPath.row])!)
            //if indexPath.row == DataService.instance.screenUserIsIn {
               // cell.cellSelected()
            //}
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print ("item \(labels[indexPath.row]) was selected!")
        tableView.deselectRow(at: indexPath, animated: true)
        self.revealViewController()!.revealLeftView()
        DataService.instance.screenUserIsIn = 0
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var controller: UIViewController?

        // deselect food diary

        if labels[indexPath.row] == "Logout" {
            controller = storyboard.instantiateViewController(withIdentifier: "MainViewController")
            revealViewController()?.setMainViewController(controller!, animated: true)
            DataService.instance.screenUserIsIn = 0
        } else if labels[indexPath.row] == "Home"{
            controller = storyboard.instantiateViewController(withIdentifier: storyboardIDs[indexPath.row])
                let nc = UINavigationController(rootViewController: controller!)
                revealViewController()?.pushMainViewController(nc, animated: true)
        } else {
            controller = storyboard.instantiateViewController(withIdentifier: storyboardIDs[indexPath.row])
//            let nc = UINavigationController(rootViewController: controller!)
//            revealViewController()?.pushMainViewController(nc, animated: true)
            present(controller!, animated: true, completion: nil)
        }
    }

    func revealController(_ revealController: PBRevealViewController, willShowLeft viewController: UIViewController) {
        print ("user was in \(labels[DataService.instance.screenUserIsIn]) and side menu was selected!")

        for i in 0..<labels.count {
            if let cell = sideMenuTable.cellForRow(at: IndexPath.init(row: i, section: 0)) as? SideMenuCell {
                cell.cellUnselected()
            }
        }

        if let cell = sideMenuTable.cellForRow(at: IndexPath.init(row: DataService.instance.screenUserIsIn, section: 0)) as? SideMenuCell {
            cell.cellSelected()
        }
    }
    @IBAction func profileButtonPressed(_ sender: Any) {
        print("Go to profile page")
        performSegue(withIdentifier: "menuToLogin", sender: nil)
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
