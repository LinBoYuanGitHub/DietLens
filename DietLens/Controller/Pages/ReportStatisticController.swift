//
//  ReportStatisticController.swift
//  DietLens
//
//  Created by linby on 29/03/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
import HFSwipeView

class ReportStatisticController: UIViewController {

}

extension ReportStatisticController: HFSwipeViewDelegate {
    func swipeView(_ swipeView: HFSwipeView, didFinishScrollAtIndexPath indexPath: IndexPath) {

    }

    func swipeView(_ swipeView: HFSwipeView, didSelectItemAtPath indexPath: IndexPath) {

    }

    func swipeView(_ swipeView: HFSwipeView, didChangeIndexPath indexPath: IndexPath, changedView view: UIView) {

    }
}

extension ReportStatisticController: HFSwipeViewDataSource {
    func swipeViewItemCount(_ swipeView: HFSwipeView) -> Int {
        return 4
    }

    func swipeViewItemSize(_ swipeView: HFSwipeView) -> CGSize {
        //TODO remove hardCode
        return CGSize(width: 50, height: 50)
    }

    func swipeView(_ swipeView: HFSwipeView, viewForIndexPath indexPath: IndexPath) -> UIView {
        let itemSize = CGSize(width: 50, height: 50)
        return UILabel(frame: CGRect(origin: .zero, size: itemSize))
    }

}
