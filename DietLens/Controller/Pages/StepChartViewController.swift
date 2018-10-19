//
//  StepChartViewController.swift
//  DietLens
//
//  Created by linby on 2018/9/12.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
import Charts
import HealthKit

class StepChartViewController: BaseViewController {

    @IBOutlet var chartView: BarChartView!
    @IBOutlet var tabLayout: UISegmentedControl!

    var visibleCountNum = 24 //one week
    @IBOutlet var emptyView: UIView!

    var stepDataList = [StepEntity]()

    override func viewDidLoad() {
        super.viewDidLoad()
        chartView.delegate = self
        chartView.drawBarShadowEnabled = false
        chartView.drawValueAboveBarEnabled = false
        chartView.maxVisibleCount = visibleCountNum
        chartView.setScaleEnabled(false)
        chartView.tintColor = UIColor(red: CGFloat(240.0/255.0), green: CGFloat(90.0/255.0), blue: CGFloat(90.0/255.0), alpha: 1.0)
        setUpXAxis()
        setUpLeftAxis()
        setUpRightAxis()
        setUpChartLegend()
        setUpMarkerView()
        requestAuthFromHealthKit()//get auth at then beginning
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    func requestAuthFromHealthKit() {
        if HKHealthStore.isHealthDataAvailable() {
            HealthKitSetupAssistant.authorizeHealthKit { (authorized, error) in

                guard authorized else {

                    let baseMessage = "HealthKit Authorization Failed"
                    self.emptyView.isHidden = false
                    if let error = error {
                        print("\(baseMessage). Reason: \(error.localizedDescription)")
                    } else {
                        print(baseMessage)
                    }
                    return
                }
                self.loadDailyStepChart()//load daily step data chart if succeed
            }
        }
    }

    func setUpMarkerView() {
        let marker = YStepMarkerView(color: UIColor(red: CGFloat(240.0/255.0), green: CGFloat(90.0/255.0), blue: CGFloat(90.0/255.0), alpha: 1.0),
                                   font: .systemFont(ofSize: 12),
                                   textColor: .white,
                                   insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
//        let marker = XYMarkerView(color: UIColor(white: 180/250, alpha: 1),
//                                  font: .systemFont(ofSize: 12),
//                                  textColor: .black,
//                                  insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8),
//                                  xAxisValueFormatter: chartView.xAxis.valueFormatter!)
        marker.chartView = chartView
        marker.minimumSize = CGSize(width: 80, height: 40)
        chartView.marker = marker
    }

    func getStepDataCallBack(steps: [StepEntity], error: Error?) {
        if error != nil {
            return
        }
        chartView.maxVisibleCount = visibleCountNum
        setChartData(steps: steps)
    }

    func setChartData(steps: [StepEntity]) {
        var yValues = [BarChartDataEntry]()
        for index in 0..<steps.count {
            let val = steps[index].stepValue
            let entity = BarChartDataEntry(x: Double(index+1), y: val)
            yValues.append(entity)
        }
        let dataSet = BarChartDataSet(values: yValues, label: "Step Data")
        let dietlensRed = [UIColor(red: CGFloat(240.0/255.0), green: CGFloat(90.0/255.0), blue: CGFloat(90.0/255.0), alpha: 1.0)]
        dataSet.colors = dietlensRed
        let data = BarChartData(dataSet: dataSet)
        //try to refresh the chartView
        chartView.data = data
        chartView.animate(xAxisDuration: 0.1)
    }

    func setUpXAxis() {
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.labelTextColor = .gray
        xAxis.granularity = 1
        xAxis.labelCount = 7
    }

    func setUpLeftAxis() {
        let leftAxis = chartView.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 10)
        leftAxis.labelTextColor = .gray
        leftAxis.labelCount = 8
//        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        leftAxis.labelPosition = .outsideChart
        leftAxis.spaceTop = 0.15
        leftAxis.axisMinimum = 0
    }

    func setUpRightAxis() {
        let rightAxis = chartView.rightAxis
        rightAxis.enabled = true
        rightAxis.labelFont = .systemFont(ofSize: 10)
        rightAxis.labelCount = 8
        rightAxis.labelTextColor = .gray
        rightAxis.spaceTop = 0.15
        rightAxis.axisMinimum = 0
    }

    func setUpChartLegend() {
        let legend = chartView.legend
        legend.horizontalAlignment = .left
        legend.verticalAlignment = .bottom
        legend.orientation = .horizontal
        legend.drawInside = false
        legend.form = .circle
        legend.formSize = 9
        legend.font = UIFont(name: "HelveticaNeue-Light", size: 11)!
        legend.xEntrySpace = 4
    }

    @IBAction func onTabItemChanged(_ sender: UISegmentedControl) {
        let tabItemIndex = sender.selectedSegmentIndex
        switch tabItemIndex {
        case 0:
            loadDailyStepChart()
        case 1:
            loadWeeklyStepChart()
        case 2:
            loadMonthlyStepChart()
        default:
            break
        }
    }

    func loadDailyStepChart() {
        visibleCountNum = 24
        HKHealthStore().getHourlyStepsCountList { (steps, error) in
            self.getStepDataCallBack(steps: steps, error: error)
        }
    }

    func loadWeeklyStepChart() {
        visibleCountNum = 7
        HKHealthStore().getWeeklyStepsCountList(anyDayOfTheWeek: Date()) { (steps, error) in
            self.getStepDataCallBack(steps: steps, error: error)
        }
    }

    func loadMonthlyStepChart() {
        visibleCountNum = 30
        HKHealthStore().getMonthlyStepsCountList(anyDayOfWeek: Date()) { (steps, error) in
            self.getStepDataCallBack(steps: steps, error: error)
        }
    }

}

extension StepChartViewController: ChartViewDelegate {

    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {

    }
}
