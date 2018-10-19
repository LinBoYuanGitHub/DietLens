//
//  YStepMarkerView.swift
//  DietLens
//
//  Created by linby on 2018/10/18.
//  Copyright © 2018 NExT++. All rights reserved.
//

import Foundation
import Charts

public class YStepMarkerView: BalloonMarker {
    fileprivate var yFormatter = NumberFormatter()

    public override init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets) {
        yFormatter.minimumFractionDigits = 1
        yFormatter.maximumFractionDigits = 1
        super.init(color: color, font: font, textColor: textColor, insets: insets)
    }

    public override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        let string = String(Int(floor(entry.y)))
        setLabel(string)
    }

}
