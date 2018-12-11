//
//  FoodRecommendationViewController.swift
//  DietLens
//
//  Created by 马胖 on 7/12/18.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class FoodRecommendationViewController: BaseViewController {
    @IBOutlet weak var prograssBarView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //设置的是圆形进度条
        let progressView = ZMProgressView()
        progressView.lineColor = UIColor.init(displayP3Red: 246 / 255, green: 16 / 255, blue: 51 / 255, alpha: 1)
        progressView.loopColor = UIColor.init(displayP3Red: 225 / 255, green: 225 / 255, blue: 225 / 255, alpha: 1)
        progressView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        progressView.isAnimatable = true
        progressView.backgroundColor = UIColor.clear
        progressView.percent = 25
        //设置标题
        progressView.title = "\(progressView.percent)%"
        progressView.percentUnit = "Complete"
        self.prograssBarView.addSubview(progressView)
        alert()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem  = UIBarButtonItem(image: UIImage(imageLiteralResourceName: "Back Arrow"), style: .plain, target: self, action: #selector(onBackPressed))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
        self.navigationItem.title = "Food Recommendation"
    }

    @objc func onBackPressed() {
        self.navigationController?.popViewController(animated: true)
    }

    func alert() {
        AlertMessageHelper.showDietLensMessage(targetController: self, message: "Activity completion refer to when you started on the clinical studies.", confirmText: "Okay", delegate: self)
        // 创建
//        let alertController = UIAlertController(title: "", message: "Activity completion refer to when you started on the clinical studies.", preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "Okay", style: .default) { (UIAlertAction) in
//            //print("点击了好的")
//        }

        // 添加

//        alertController.addAction(okAction)

        // 弹出
//        self.present(alertController, animated: true, completion: nil)
    }
}

extension FoodRecommendationViewController: ConfirmationDialogDelegate {

    func onConfirmBtnPressed() {
        self.dismiss(animated: true, completion: nil)
    }

}
