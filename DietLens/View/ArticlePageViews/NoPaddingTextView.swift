//
//  NoPaddingTextView.swift
//  DietLens
//
//  Created by next on 11/11/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit

@IBDesignable
class NoPaddingTextView: UITextView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override func prepareForInterfaceBuilder() {
        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    func setup() {
        textContainerInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = 0
    }
}
