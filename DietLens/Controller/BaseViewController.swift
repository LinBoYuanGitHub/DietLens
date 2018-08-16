//
//  BaseViewController.swift
//  DietLens
//
//  Created by linby on 2018/7/13.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
class BaseViewController: UIViewController {
    let loadingView = UIView()
    let loadingIndicatonLength: CGFloat = 40 //indicator length
    let viewHeight: CGFloat = 80
    let viewWidth: CGFloat = 200
    let textLabelWidth: CGFloat = 200
    let textLabelHeight: CGFloat = 20

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        //set status bar appearance
        UIApplication.shared.statusBarStyle = .default
        //navigation controller
        self.navigationController?.navigationBar.isHidden = false
        let textColor = UIColor(red: CGFloat(67/255), green: CGFloat(67/255), blue: CGFloat(67/255), alpha: 1.0)
        if let attributeGroup = [NSAttributedStringKey.foregroundColor: textColor, kCTFontAttributeName: UIFont(name: "PingFangSC-Regular", size: 18)!] as? [NSAttributedStringKey: Any] {
             self.navigationController?.navigationBar.titleTextAttributes = attributeGroup
        }
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }

    func showLoadingDialog() {
        //loading UI view
        loadingView.frame = CGRect(x: self.view.frame.width/2, y: self.view.frame.height/2, width: viewWidth, height: viewHeight)
        loadingView.backgroundColor = UIColor.black
        //spinner
        let spinnerIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        spinnerIndicator.frame = CGRect(x: 0, y: 0, width: loadingIndicatonLength, height: loadingIndicatonLength)
        spinnerIndicator.center = CGPoint(x: loadingView.frame.width/2, y: loadingView.frame.height/2)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        loadingView.addSubview(spinnerIndicator)
        //add label
        let textLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: textLabelWidth, height: textLabelHeight))
        textLabel.center =  CGPoint(x: loadingView.frame.width/2, y: spinnerIndicator.frame.origin.y - loadingIndicatonLength)
        textLabel.textColor = UIColor.black
        textLabel.text = "Loading"
        loadingView.addSubview(textLabel)
        UIApplication.shared.keyWindow?.addSubview(loadingView)
    }

    func hideLoadingDialog() {
        loadingView.removeFromSuperview()
    }

}
