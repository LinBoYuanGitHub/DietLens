//
//  HomeViewController.swift
//  DietLens
//
//  Created by next on 24/10/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "newsFeedCell") as? NewsFeedCell
        {
            return cell
        }
        else
        {
            return NewsFeedCell()
        }
    }
    

    @IBOutlet weak var newsFeedTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newsFeedTable.dataSource = self
        newsFeedTable.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
