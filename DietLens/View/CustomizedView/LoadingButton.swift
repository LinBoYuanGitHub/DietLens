//
//  LoadingButton.swift
//  DietLens
//
//  Created by linby on 2018/7/24.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class LoadingButton: UIButton {

    var originalButtonText: String?
    var loadingImageView: UIImageView?
    var activityIndicator: UIActivityIndicatorView!

    func showLoading() {
        originalButtonText = self.titleLabel?.text
        self.setTitle("", for: .normal)
        self.imageView?.isHidden = true
//        if activityIndicator == nil {
//            activityIndicator = createActivityIndicator()
//        }
        if loadingImageView == nil {
            loadingImageView = createImageViewIndicator()
        }
        showSpinning()
    }

    func hideLoading() {
        self.setTitle(originalButtonText, for: .normal)
        self.imageView?.isHidden = false
        if loadingImageView != nil {
            loadingImageView?.stopAnimating()
            loadingImageView?.isHidden = true
        }
    }

    private func createActivityIndicator() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .lightGray
        return activityIndicator
    }

    private func createImageViewIndicator() -> UIImageView {
        let activityImageIndicator = UIImageView()
        activityImageIndicator.image = #imageLiteral(resourceName: "recognitionLoadingImage")
        return activityImageIndicator
    }

    private func showSpinning() {
//        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
//        self.addSubview(activityIndicator)
//        centerActivityIndicatorInButton()
//        activityIndicator.startAnimating()
        loadingImageView?.translatesAutoresizingMaskIntoConstraints = false
        loadingImageView?.isHidden = false
        self.addSubview(loadingImageView!)
        centerActivityIndicatorInButton()
//        loadingImageView?.startAnimating()
        rotate(imageView: loadingImageView!)
    }

    private func centerActivityIndicatorInButton() {
        let xCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: loadingImageView, attribute: .centerX, multiplier: 1, constant: 0)
        self.addConstraint(xCenterConstraint)

        let yCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: loadingImageView, attribute: .centerY, multiplier: 1, constant: 0)
        self.addConstraint(yCenterConstraint)
    }

    func rotate(imageView: UIImageView) {
        let rotation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: M_PI * 2)
        rotation.duration = 1
        rotation.isCumulative = true
        rotation.repeatCount = FLT_MAX
        imageView.layer.add(rotation, forKey: "rotationAnimation")
    }
}
