//
//  HomeViewController.swift
//  DietLens
//
//  Created by next on 24/10/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit
import PBRevealViewController

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var sideMenuButton: UIBarButtonItem!

    @IBOutlet weak var newsFeedTable: UITableView!

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "newsFeedRow") as? NewsFeedCell {
                return cell
            }
        } else if indexPath.row == 1 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "otherFeedRow") //as? UITableViewCell
            {
                return cell
            }
        }

        return UITableViewCell()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        newsFeedTable.dataSource = self
        newsFeedTable.delegate = self
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedStringKey.font: UIFont(name: "SignPainterHouseScript", size: 32), NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.6347548905, green: 0.6361853982, blue: 0.6580147525, alpha: 1)]
        sideMenuButton.target = self.revealViewController()
        sideMenuButton.action = #selector(PBRevealViewController.revealLeftView)
        revealViewController()?.leftViewBlurEffectStyle = .light
        //self.addLeftBarButtonWithImage(<#T##buttonImage: UIImage##UIImage#>)
        newsFeedTable.estimatedRowHeight = 240
        newsFeedTable.rowHeight = UITableViewAutomaticDimension
        // Do any additional setup after loading the view.
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return CGFloat(240)
        } else if indexPath.row == 1 {
            return CGFloat(320)
        } else {
            return UITableViewAutomaticDimension
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
