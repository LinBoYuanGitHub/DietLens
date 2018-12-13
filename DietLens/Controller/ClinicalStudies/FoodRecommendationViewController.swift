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
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!

    var entity = ClinicalStudyEntity.init()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //set progress
        let progressView = ZMProgressView()
        progressView.lineColor = UIColor.init(hex: 0xfa2c42)
        progressView.loopColor = UIColor.init(displayP3Red: 225 / 255, green: 225 / 255, blue: 225 / 255, alpha: 1)
        progressView.frame = CGRect(x: 0, y: 0, width: 149, height: 149)
        progressView.isAnimatable = true
        progressView.backgroundColor = UIColor.clear

        progressView.percent = calculatePercent()    //set number of progress
        let percentint = Int(progressView.percent)
        //set title
        progressView.title = "\(percentint)%"
        progressView.percentUnit = "Complete"
        self.prograssBarView.addSubview(progressView)

    }
    //Calculate the percent of progressView
    func calculatePercent() -> CGFloat {
        //get current date
        let date = Date()
        let zone = NSTimeZone.system
        let interval = zone.secondsFromGMT()
        let now = date.addingTimeInterval(TimeInterval(interval))

        //Calculate the percent
        let percent = Float(calculateDays(startDate: self.entity.content.startDate, endDate: now) * 100 / calculateDays(startDate: self.entity.content.startDate, endDate: self.entity.content.endDate))

        return CGFloat(percent)
    }

    //set the date in the UI
    func setStartandEndDate() {
        //change the format of date
        let startDate = DateUtil.formatGMTDateToString(date: self.entity.content.startDate)
        let endDate = DateUtil.formatGMTDateToString(date: self.entity.content.endDate)
        let startTime = DateUtil.hourMinDateToString(date: self.entity.content.startDate)
        let endTime = DateUtil.hourMinDateToString(date: self.entity.content.endDate)

        let start = "Started on " + startDate + "," + startTime + ",Singapore time"
        let end = "End on " + endDate + "," + endTime + ",Singapore time"

        //set date
        startDateLabel.text = start
        endDateLabel.text = end
    }
    //Calculate the numbers of days
    func calculateDays(startDate: Date, endDate: Date) -> Int {
        let userCalendar = Calendar.current
        let between = userCalendar.dateComponents([.day], from: startDate, to: endDate)
        return between.day!
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem  = UIBarButtonItem(image: UIImage(imageLiteralResourceName: "Back Arrow"), style: .plain, target: self, action: #selector(onBackPressed))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
        self.navigationItem.title = "Study"

        setStartandEndDate()
    }

    @objc func onBackPressed() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func touchQuestionButton(_ sender: UIButton) {
       alert()
    }
    func alert() {
        AlertMessageHelper.showDietLensMessage(targetController: self, message: "Activity completion refer to when you started on the clinical studies.", confirmText: "Okay", delegate: self)

    }
}

extension FoodRecommendationViewController: ConfirmationDialogDelegate {

    func onConfirmBtnPressed() {
        self.dismiss(animated: true, completion: nil)
    }

}
