//
//  Modal.swift
//  DietLens
//
//  Created by linby on 2018/5/18.
//  Copyright © 2018 NExT++. All rights reserved.
//  Create Modal extension to show modal dialog

import UIKit

protocol Modal {
    func show(animated: Bool)
    func dismiss(animated: Bool)
    var backgroundView: UIView {get}
    var dialogView: UIView {get set}
}

extension Modal where Self: UIView {
    func show(animated: Bool) {
        self.backgroundView.alpha = 0
        self.dialogView.center = CGPoint(x: self.center.x, y: self.frame.height + self.dialogView.frame.height/2)
        UIApplication.shared.delegate?.window??.rootViewController?.view.addSubview(self)
        if animated {
            UIView.animate(withDuration: 0.33, animations: {
                self.backgroundView.alpha = 0.66
            })
            UIView.animate(withDuration: 0.33, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 10, options: UIViewAnimationOptions(rawValue: 0), animations: {
                self.dialogView.center  = self.center
            }, completion: { (_) in

            })
        } else {
            self.backgroundView.alpha = 0.66
            self.dialogView.center  = self.center
        }
    }

    func dismiss(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.33, animations: {
                self.backgroundView.alpha = 0
            }, completion: { (_) in

            })
            UIView.animate(withDuration: 0.33, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 10, options: UIViewAnimationOptions(rawValue: 0), animations: {
                self.dialogView.center = CGPoint(x: self.center.x, y: self.frame.height + self.dialogView.frame.height/2)
            }, completion: { (_) in
                self.removeFromSuperview()
            })
        } else {
            self.removeFromSuperview()
        }

    }
}
