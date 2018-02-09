//
//  expandedUITextField.swift
//  DietLens
//
//  Created by linby on 20/01/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class ExpandedUITextField: UITextField {
    var addedTouchArea = CGFloat(0)

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {

        let newBound = CGRect(
            x: self.bounds.origin.x - 10,
            y: self.bounds.origin.y - 30,
            width: self.bounds.width + 2 * 10,
            height: self.bounds.width + 2 * 30
        )
        return newBound.contains(point)
    }
}
