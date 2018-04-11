//
//  ReportTableCell.swift
//  DietLens
//
//  Created by linby on 20/12/2017.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit

class ReportTableCell: UITableViewCell {

    @IBOutlet weak var colorEdgeView: UIView!

    @IBOutlet weak var averageLabelView: UILabel!

    @IBOutlet weak var valueLabelView: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setupReportCell(reportLabel name: String, ReportValue value: String, ReportStandard standard: String) {
        averageLabelView.text = name
        valueLabelView.text = "\(value) of \(standard)"
    }
}
