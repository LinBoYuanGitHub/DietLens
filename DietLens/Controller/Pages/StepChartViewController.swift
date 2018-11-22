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
import FirebaseAnalytics

class StepChartViewController: BaseViewController {

    @IBOutlet var chartView: BarChartView!
    @IBOutlet var tabLayout: UISegmentedControl!

    var visibleCountNum = 24 //one week
    @IBOutlet var emptyView: UIView!

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var leftArrow: UIButton!
    @IBOutlet weak var rightArrow: UIButton!

    var stepDataList = [StepEntity]()
    var dateMode = StringConstants.DateMode.day // 0 day,1 week, 2 month, 3 year

    var marker: YStepMarkerView!

    var currentDate = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
//        let timeZoneStr = TimeZone.current.abbreviation()
        let formatComponent = Calendar.current.dateComponents([.day, .month, .year], from: Date())
//        formatComponent.timeZone = TimeZone(abbreviation: "UTC")
        currentDate = Calendar.current.date(from: formatComponent)!
        chartView.delegate = self
        chartView.drawBarShadowEnabled = false
        chartView.drawValueAboveBarEnabled = false
        chartView.maxVisibleCount = visibleCountNum
        chartView.highlightFullBarEnabled = false
        chartView.setScaleEnabled(false)
        chartView.tintColor = UIColor(red: CGFloat(240.0/255.0), green: CGFloat(90.0/255.0), blue: CGFloat(90.0/255.0), alpha: 1.0)
        chartView.chartDescription?.text = ""
        setUpXAxis(labelCount: 24, granularity: 3)//hour
        dateLabel.text = DateUtil.formatGMTDateToString(date: currentDate)
        setUpLeftAxis()
        setUpRightAxis()
        setUpChartLegend()
        setUpMarkerView()
        requestAuthFromHealthKit()//get auth at then beginning
        rightArrow.isEnabled = false //disable rightArrow
        //analytic screen name
        Analytics.setScreenName("StepCounterPage", screenClass: "StepChartViewController")
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
        marker = YStepMarkerView(color: UIColor(red: CGFloat(240.0/255.0), green: CGFloat(90.0/255.0), blue: CGFloat(90.0/255.0), alpha: 1.0),
                                   font: .systemFont(ofSize: 14),
                                   textColor: .white,
                                   insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
//        let marker = XYMarkerView(color: UIColor(white: 180/250, alpha: 1),
//                                  font: .systemFont(ofSize: 12),
//                                  textColor: .black,
//                                  insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8),
//                                  xAxisValueFormatter: chartView.xAxis.valueFormatter!)
        marker.chartView = chartView
        marker.minimumSize = CGSize(width: 80, height: 50)
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
            var xAxisVal = 0.0
            guard let xDate = steps[index].date else {
                return
            }
            switch dateMode {
            case .day:
                xAxisVal = Double(index)
            case .week:
                var weekday = Calendar.current.component(.weekday, from: xDate)
                //TODO hard approach to fix the timeZone issue, need to be gentle
                if weekday == 1 {
                    weekday = 8
                }
                xAxisVal = Double(weekday-1)
            case .month:
                let monthDay = Calendar.current.component(.day, from: xDate)
                xAxisVal = Double(monthDay)
            case .year:
                let month = Calendar.current.component(.month, from: xDate)
                xAxisVal = Double(month)
            }
            let entity = BarChartDataEntry(x: xAxisVal, y: val)
            yValues.append(entity)
        }
        let dataSet = BarChartDataSet(values: yValues, label: "Steps")
        let dietlensRed = [UIColor(red: CGFloat(240.0/255.0), green: CGFloat(90.0/255.0), blue: CGFloat(90.0/255.0), alpha: 1.0)]
        dataSet.highlightColor = UIColor(red: CGFloat(240.0/255.0), green: CGFloat(90.0/255.0), blue: CGFloat(90.0/255.0), alpha: 1.0)
        dataSet.colors = dietlensRed
        let data = BarChartData(dataSet: dataSet)
        data.setDrawValues(false)
        //try to refresh the chartView
        chartView.data = data
        chartView.animate(xAxisDuration: 0.1)
    }

    func setUpXAxis(labelCount: Int, granularity: Int) {
        let xAxis = chartView.xAxis
        xAxis.drawGridLinesEnabled = true
        xAxis.gridLineWidth = 0.5
        xAxis.gridLineDashLengths = [4, 2]
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.labelTextColor = .gray
        xAxis.granularity = Double(granularity)
        xAxis.valueFormatter = self
        xAxis.labelCount = labelCount
        xAxis.axisMaximum = Double(labelCount + granularity)
        xAxis.granularityEnabled = true
    }

    func setUpLeftAxis() {
        let leftAxis = chartView.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 10)
        leftAxis.labelTextColor = .gray
        leftAxis.labelCount = 5
//        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        leftAxis.labelPosition = .outsideChart
        leftAxis.spaceTop = 0.15
        leftAxis.axisMinimum = 0
    }

    func setUpRightAxis() {
        let rightAxis = chartView.rightAxis
        rightAxis.enabled = true
        rightAxis.labelFont = .systemFont(ofSize: 10)
        rightAxis.labelCount = 0
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
        case 3:
            loadYearlyStepChart()
        default:
            break
        }
        marker.dateMode = dateMode
    }

    func loadDailyStepChart() {
        visibleCountNum = 24
        dateMode = StringConstants.DateMode.day
        dateLabel.text = DateUtil.formatGMTDateToString(date: currentDate)
        setUpXAxis(labelCount: visibleCountNum, granularity: 3)
        HKHealthStore().getHourlyStepsCountList(inputDate: currentDate) { (steps, error) in
            self.getStepDataCallBack(steps: steps, error: error)
        }
    }

    func loadWeeklyStepChart() {
        visibleCountNum = 7
        dateMode = StringConstants.DateMode.week
        setUpXAxis(labelCount: visibleCountNum, granularity: 1)
        dateLabel.text = DateUtil.formatGMTDateToString(date: currentDate.beginOfWeek!) + "-" +  DateUtil.formatGMTDateToString(date: currentDate.endOfWeek!)
        HKHealthStore().getWeeklyStepsCountList(anyDayOfTheWeek: currentDate) { (steps, error) in
            self.getStepDataCallBack(steps: steps, error: error)
        }
    }

    func loadMonthlyStepChart() {
        visibleCountNum = 31
        dateMode = StringConstants.DateMode.month
        dateLabel.text = DateUtil.formatMonthWithYearToString(date: currentDate)
        setUpXAxis(labelCount: visibleCountNum, granularity: 5)
        HKHealthStore().getMonthlyStepsCountList(anyDayOfMonth: currentDate) { (steps, error) in
            self.getStepDataCallBack(steps: steps, error: error)
        }
    }

    func loadYearlyStepChart() {
        visibleCountNum = 12
        dateMode = StringConstants.DateMode.year
        dateLabel.text = DateUtil.formatYearToString(date: currentDate)
        setUpXAxis(labelCount: visibleCountNum, granularity: 1)
        HKHealthStore().getYearlyStepsCounterList(anyDayOfYear: currentDate) { (steps, error) in
            self.getStepDataCallBack(steps: steps, error: error)
        }
    }

    @IBAction func onLeftArrowPressed(_ sender: Any) {
        dateTimeSwitch(addingValue: -1)
    }

    @IBAction func onRightArrowPressed(_ sender: Any) {
        dateTimeSwitch(addingValue: 1)
    }

    func dateTimeSwitch(addingValue: Int) {
        switch dateMode {
        case .day:
            currentDate = Calendar.current.date(byAdding: Calendar.Component.day, value: addingValue, to: currentDate)!
            rightArrow.isEnabled = Date() > Calendar.current.date(byAdding: Calendar.Component.day, value: addingValue, to: currentDate)!
            loadDailyStepChart()
        case .week:
            currentDate = Calendar.current.date(byAdding: Calendar.Component.weekOfMonth, value: addingValue, to: currentDate)!
            rightArrow.isEnabled = Date() > Calendar.current.date(byAdding: Calendar.Component.weekOfYear, value: addingValue, to: currentDate)!
            loadWeeklyStepChart()
        case .month:
            currentDate = Calendar.current.date(byAdding: Calendar.Component.month, value: addingValue, to: currentDate)!
            rightArrow.isEnabled = Date() > Calendar.current.date(byAdding: Calendar.Component.month, value: addingValue, to: currentDate)!
            loadMonthlyStepChart()
        case .year:
            currentDate = Calendar.current.date(byAdding: Calendar.Component.year, value: addingValue, to: currentDate)!
            rightArrow.isEnabled = Date() > Calendar.current.date(byAdding: Calendar.Component.year, value: addingValue, to: currentDate)!
            loadYearlyStepChart()
        }
    }

}

extension StepChartViewController: ChartViewDelegate {

    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {

    }
}

extension StepChartViewController: IAxisValueFormatter {

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        switch dateMode {
        case .day:
            if Int(value) > 24 {
                return ""
            } else {
                return String(Int(value))
            }
        case .week:
            if Int(value - 1) >= StringConstants.DateString.weekString.count {
                return ""
            } else {
                return StringConstants.DateString.weekString[Int(value - 1)]
            }
        case .month:
            if Int(value) > 31 {
                return ""
            } else {
                return String(Int(value))
            }
        case .year:
            if Int(value - 1) >= StringConstants.DateString.monthString.count {
                return ""
            } else {
                return StringConstants.DateString.monthString[Int(value - 1)]
            }
        }
    }
}
