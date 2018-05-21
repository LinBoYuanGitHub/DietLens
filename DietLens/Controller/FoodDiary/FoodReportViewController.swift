//
//  FoodReportViewController.swift
//  DietLens
//
//  Created by linby on 10/04/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class FoodReportViewController: UIViewController {

    @IBOutlet weak var foodReportTextView: UITextView!
    @IBOutlet weak var reportedImage: UIImageView!
    var sourceImage: UIImage!

    override func viewDidLoad() {
        reportedImage.image = sourceImage
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = StringConstants.NavigatorTitle.reportTitle
    }

    func uploadReportImageToServer() {

    }

}
