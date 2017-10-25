//
//  HomeViewController.swift
//  DietLens
//
//  Created by next on 24/10/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var newsFeedTable: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "newsFeedRow") as? NewsFeedCell
        {
            return cell
        }
        else if let cell = tableView.dequeueReusableCell(withIdentifier: "otherFeedRow") as? UITableViewCell
        {
            return cell
        }
        else
        {
            return NewsFeedCell()
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        newsFeedTable.dataSource = self
        newsFeedTable.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

