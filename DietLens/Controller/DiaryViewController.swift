//
//  DiaryViewController.swift
//  DietLens
//
//  Created by next on 26/10/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit

class DiaryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var diaryTable: UITableView!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0
        {
            return tableView.dequeueReusableCell(withIdentifier: "cell1")!
        }
        else
        {
            return tableView.dequeueReusableCell(withIdentifier: "cell2")!
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        diaryTable.dataSource = self
        diaryTable.delegate = self
        diaryTable.estimatedRowHeight = 90
        diaryTable.rowHeight = UITableViewAutomaticDimension
        
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(),for:.default)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}
