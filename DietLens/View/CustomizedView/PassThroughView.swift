//
//  PassThroughView.swift
//  DietLens
//
//  Created by boyuan lin on 21/12/18.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class PassThroughView: UIView {

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews {
            if !subview.isHidden && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event) {
                return true
            }
        }
        return false
    }

}
