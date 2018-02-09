//
//  ExpandedUIButton.swift
//  DietLens
//
//  Created by linby on 15/01/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import Foundation
import UIKit

class ExpandedUIButton: UIButton {

    var addedTouchArea = CGFloat(0)

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {

        let newBound = CGRect(
            x: self.bounds.origin.x - 17,
            y: self.bounds.origin.y - 17,
            width: self.bounds.width + 2 * 17,
            height: self.bounds.width + 2 * 17
        )
        return newBound.contains(point)
    }
}
