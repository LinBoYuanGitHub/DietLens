//
//  CustomAlertView.swift
//  DietLens
//
//  Created by linby on 2018/5/18.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

protocol SingleOptionAlerViewDelegate: class {
    func onSaveBtnClicked(selectedPosition: Int)
    func onCancel()
}

class SingleOptionViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var singleSelectionTable: UITableView!

    //delegate for single option
    var delegate: SingleOptionAlerViewDelegate?
    //option item List, for display the item
    var optionList = [String]()
//    var title = ""
    var selectedPosition = 0

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func save() {
        delegate?.onSaveBtnClicked(selectedPosition: selectedPosition)
    }

    @IBAction func cancel(_ sender: Any) {
        delegate?.onCancel()
    }

}

extension SingleOptionViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPosition = indexPath.row
        //change the selection indicator
    }

}
