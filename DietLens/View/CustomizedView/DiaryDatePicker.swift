//
//  DiaryDatePicker.swift
//  DietLens
//
//  Created by next on 9/11/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit
import FSCalendar

class DiaryDatePicker: FSCalendar {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 20
    }

}
