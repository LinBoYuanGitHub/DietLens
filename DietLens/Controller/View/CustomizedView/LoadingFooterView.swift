//
//  LoadingFooterView.swift
//  DietLens
//
//  Created by linby on 2018/7/23.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class LoadingFooterView: UIView {

    var loadingIndicatorWidth: CGFloat = 25
    var loadingIndicatorHeight: CGFloat = 25

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeSubviews(parentFrame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initializeSubviews(parentFrame: CGRect) {
        //set background color
        self.backgroundColor = UIColor.white
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: loadingIndicatorWidth, height: loadingIndicatorHeight))
        loadingIndicator.center = CGPoint(x: parentFrame.size.width/2, y: parentFrame.size.height/2)
        loadingIndicator.color = UIColor.gray
        self.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
    }

}
