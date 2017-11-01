//
//  ProfileImageView.swift
//  DietLens
//
//  Created by next on 31/10/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit

@IBDesignable
class ProfileImageView: UIImageView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBInspectable var cornerRadius: CGFloat = 2.0
    {
        didSet
        {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    override func awakeFromNib()
    {
        self.setupView()
    }
    
    func setupView()
    {
        self.layer.cornerRadius = cornerRadius
    }
    
    override func prepareForInterfaceBuilder()
    {
        super.prepareForInterfaceBuilder()
        self.setupView()
    }

}
