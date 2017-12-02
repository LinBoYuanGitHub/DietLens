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
    @IBOutlet weak var fatsProgressBar: HomeProgressView!
    @IBOutlet weak var proteinProgressBar: HomeProgressView!
    @IBOutlet weak var carbohydrateProgressBar: HomeProgressView!

    @IBOutlet weak var headerView: UIView!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "newsFeedRow") as? NewsFeedCell {
                cell.selectionStyle = .none
                return cell
            }
        } else if indexPath.row == 1 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "otherFeedRow") //as? UITableViewCell
            {
                cell.selectionStyle = .none
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
            NSAttributedStringKey.font: UIFont(name: "SignPainterHouseScript", size: 32)!, NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.6347548905, green: 0.6361853982, blue: 0.6580147525, alpha: 1)]

        sideMenuButton.target = self.revealViewController()
        sideMenuButton.action = #selector(PBRevealViewController.revealLeftView)
        revealViewController()?.leftViewBlurEffectStyle = .light
        newsFeedTable.estimatedRowHeight = 240
        newsFeedTable.rowHeight = UITableViewAutomaticDimension
        self.fatsProgressBar.progress = 0.01
        self.proteinProgressBar.progress = 0.01
        self.carbohydrateProgressBar.progress = 0.01
        // Do any additional setup after loading the view.
        UIView.animate(withDuration: 1.8, delay: 1.2, options: .curveLinear, animations: { self.fatsProgressBar.setProgress(0.9, animated: true) }, completion: nil)
        UIView.animate(withDuration: 1.6, delay: 1.2, options: .curveLinear, animations: { self.proteinProgressBar.setProgress(0.7, animated: true) }, completion: nil)
        UIView.animate(withDuration: 1.7, delay: 1.2, options: .curveLinear, animations: { self.carbohydrateProgressBar.setProgress(0.8, animated: true) }, completion: nil)
        newsFeedTable.tableHeaderView = headerView
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

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

    @IBAction func presentCamera(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "AddFoodScreen", bundle: nil)
        guard let vc = storyboard.instantiateInitialViewController()
            else { return }
        present(vc, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
