//
//  PlainTextTableAdapter.swift
//  DietLens
//
//  Created by linby on 07/12/2017.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation
import UIKit

class PlainTextTableAdapter<CellType: UITableViewCell>: NSObject, UITableViewDataSource, UITableViewDelegate {
    public var textList = [String]()

    override init() {
        super.init()
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return textList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ingredientItemCell") //UITableViewCell()
        cell?.textLabel?.text = "\(textList[indexPath.row])"
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}
