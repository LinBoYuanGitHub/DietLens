//
//  WhiteBorderClearButton.swift
//  DietLens
//
//  Created by next on 24/10/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit

@IBDesignable
class WhiteBorderClearButton: UIButton {
    
    @IBInspectable var borderColour: UIColor = UIColor.white
    {
        didSet
        {
            layer.borderColor = borderColour.cgColor
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 2.0
    {
        didSet
        {
            layer.borderWidth = borderRadius
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var borderRadius: CGFloat = 2.0
    {
        didSet
        {
            layer.cornerRadius = borderRadius
            self.setNeedsLayout()
        }
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        clipsToBounds = true
    }
    
}
