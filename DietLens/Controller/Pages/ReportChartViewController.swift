//
//  ReportChartController.swift
//  DietLens
//
//  Created by linby on 18/12/2017.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation
import UIKit
import ScrollableGraphView

class ReportChartViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var reportTableView: UITableView!
    @IBOutlet weak var lineLabel: UILabel!

    @IBOutlet weak var emptyView: UILabel!
    var reportList = [ReportEntity]()
    var calorieList = [Float]()
    var carbohydrateList = [Float]()
    var proteinList = [Float]()
    var fatList = [Float]()

    var graphDataDict: [String: Double] = [:]
    var graphDataSortedKeys = [String]()

    var foodDiaryList = [FoodDiaryModel]()

    //counting report entity
    var reportCountingList = [ReportCountingEntity]()

    var graphView: ScrollableGraphView!

    override func viewDidLoad() {
        reportTableView.delegate = self
        reportTableView.dataSource  = self
        reportTableView.bounces = false
        loadReportData()
        initGraphView()
    }

    func initGraphView() {
        graphView = ScrollableGraphView(frame: containerView.frame, dataSource: self)
        let linePlot = LinePlot(identifier: "line") // Identifier should be unique for each plot.
        linePlot.lineStyle = .smooth
        linePlot.lineColor = .white
        //refreence line
        let referenceLines = ReferenceLines()
        referenceLines.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 10)
        referenceLines.referenceLineColor = UIColor.white.withAlphaComponent(0.5)
        referenceLines.referenceLineLabelColor = UIColor.white
        referenceLines.dataPointLabelFont = UIFont.boldSystemFont(ofSize: 8)
        referenceLines.dataPointLabelColor = UIColor.white
        referenceLines.dataPointLabelsSparsity = 1

        graphView.addPlot(plot: linePlot)
        graphView.addReferenceLines(referenceLines: referenceLines)
        graphView.bottomMargin = 5
        graphView.backgroundFillColor = UIColor.clear
        graphView.backgroundColor = UIColor.clear
        graphView.shouldAdaptRange = true
        graphView.shouldRangeAlwaysStartAtZero  = true
        graphView.shouldAnimateOnStartup = true
        graphView.center = CGPoint(x: containerView.frame.size.width/2, y: containerView.frame.size.height/2)
        graphView.showsHorizontalScrollIndicator = false
        graphView.fs_height = 180
        containerView.addSubview(graphView)
    }

    func loadReportData() {
        let diaryDateFormatter = DateFormatter()
        diaryDateFormatter.setLocalizedDateFormatFromTemplate("yyyyMMM")
        let dateString: String = diaryDateFormatter.string(from: Date())
        let year = String(dateString[4...])
        let month = String(dateString[..<3])
//        let year = "2017"
//        let month = "Dec"
        foodDiaryList = FoodDiaryDBOperation.instance.getFoodDiaryByMonth(year: String(year), month: String(month))!
        //calculate meal counting part, count times & average
        for _ in 0..<4 {
            reportCountingList.append(ReportCountingEntity())
        }
        for foodDiary in foodDiaryList {
            switch foodDiary.mealType {
            case StringConstants.MealString.breakfast:
                reportCountingList[0].name = StringConstants.MealString.breakfast
                accumulateReportCountingList(index: 0, foodDiary: foodDiary)
            case StringConstants.MealString.lunch:
                reportCountingList[1].name = StringConstants.MealString.lunch
                accumulateReportCountingList(index: 1, foodDiary: foodDiary)
            case StringConstants.MealString.dinner:
                reportCountingList[2].name = StringConstants.MealString.dinner
                accumulateReportCountingList(index: 2, foodDiary: foodDiary)
            case StringConstants.MealString.snack:
                reportCountingList[3].name = StringConstants.MealString.snack
                accumulateReportCountingList(index: 3, foodDiary: foodDiary)
            default:
                break
            }
        }
        setUpData(type: "calorie")
    }

    /**
     * sum up the total nutrition information
     *  calculate the accumulate meal times
     */
    func accumulateReportCountingList(index: Int, foodDiary: FoodDiaryModel) {
        reportCountingList[index].countsNum += 1
        reportCountingList[index].sumCalorie += Double(foodDiary.foodInfoList[foodDiary.selectedFoodInfoPos].calorie)
        reportCountingList[index].sumCarbo +=  Double(foodDiary.foodInfoList[foodDiary.selectedFoodInfoPos].carbohydrate)!
        reportCountingList[index].sumProtein +=  Double(foodDiary.foodInfoList[foodDiary.selectedFoodInfoPos].protein)!
        reportCountingList[index].sumFat +=  Double(foodDiary.foodInfoList[foodDiary.selectedFoodInfoPos].fat)!
    }

    func setUpData(type: String) {
        graphDataDict.removeAll()
        reportList.removeAll()
        if foodDiaryList.count == 0 {
            emptyView.isHidden = false
            reportList.append(ReportEntity(name: "Average Calories(kcal):", value: "0", standard: "2600"))
            reportList.append(ReportEntity(name: "Average Carbs(g):", value: "0", standard: "300"))
            reportList.append(ReportEntity(name: "Average Protein(g):", value: "0", standard: "100"))
            reportList.append(ReportEntity(name: "Average Fat(g):", value: "0", standard: "100"))
            reportTableView.reloadData()
            return
        }
        emptyView.isHidden = true
        var calorieAverage: Int = 0
        var carbohydrateAverage: Int = 0
        var proteinAverage: Int = 0
        var fatAverage: Int = 0

        var calorieSum: Float = 0
        var carbohydrateSum: Float = 0
        var proteinSum: Float = 0
        var fatSum: Float = 0
        for foodDiary in foodDiaryList {
            switch type {
            case "calorie":
                    if graphDataDict[foodDiary.mealTime] == nil {
                        graphDataDict[foodDiary.mealTime] = Double(foodDiary.foodInfoList[foodDiary.selectedFoodInfoPos].calorie)
                    } else {
                        graphDataDict[foodDiary.mealTime] = graphDataDict[foodDiary.mealTime]! + Double(foodDiary.foodInfoList[foodDiary.selectedFoodInfoPos].calorie)
                    }
            case "carbo":
                    if graphDataDict[foodDiary.mealTime] == nil {
                        graphDataDict[foodDiary.mealTime] = Double(foodDiary.foodInfoList[foodDiary.selectedFoodInfoPos].carbohydrate)
                    } else {
                        graphDataDict[foodDiary.mealTime] = graphDataDict[foodDiary.mealTime]! + Double(foodDiary.foodInfoList[foodDiary.selectedFoodInfoPos].carbohydrate)!
                    }
            case "protein":
                    if graphDataDict[foodDiary.mealTime] == nil {
                        graphDataDict[foodDiary.mealTime] = Double(foodDiary.foodInfoList[foodDiary.selectedFoodInfoPos].protein)
                    } else {
                        graphDataDict[foodDiary.mealTime] = graphDataDict[foodDiary.mealTime]! + Double(foodDiary.foodInfoList[foodDiary.selectedFoodInfoPos].protein)!
                    }
            case "fat":
                    if graphDataDict[foodDiary.mealTime] == nil {
                        graphDataDict[foodDiary.mealTime] = Double(foodDiary.foodInfoList[foodDiary.selectedFoodInfoPos].fat)
                    } else {
                        graphDataDict[foodDiary.mealTime] = graphDataDict[foodDiary.mealTime]! + Double(foodDiary.foodInfoList[foodDiary.selectedFoodInfoPos].fat)!
                    }
            default:
                break
            }
            calorieList.append(Float(foodDiary.foodInfoList[foodDiary.selectedFoodInfoPos].calorie))
            carbohydrateList.append(Float(foodDiary.foodInfoList[foodDiary.selectedFoodInfoPos].carbohydrate)!)
            proteinList.append(Float(foodDiary.foodInfoList[foodDiary.selectedFoodInfoPos].protein)!)
            fatList.append(Float(foodDiary.foodInfoList[foodDiary.selectedFoodInfoPos].fat)!)
            calorieSum += Float(foodDiary.foodInfoList[foodDiary.selectedFoodInfoPos].calorie)
            carbohydrateSum += Float(foodDiary.foodInfoList[foodDiary.selectedFoodInfoPos].carbohydrate)!
            proteinSum += Float(foodDiary.foodInfoList[foodDiary.selectedFoodInfoPos].protein)!
            fatSum += Float(foodDiary.foodInfoList[foodDiary.selectedFoodInfoPos].fat)!
        }
        calorieAverage = Int(calorieSum/Float(graphDataDict.count))
        carbohydrateAverage = Int(carbohydrateSum/Float(graphDataDict.count))
        proteinAverage = Int(proteinSum/Float(graphDataDict.count))
        fatAverage = Int(fatSum/Float(graphDataDict.count))
        graphDataSortedKeys = Array(graphDataDict.keys).sorted(by: <)
        reportList.append(ReportEntity(name: "Average Calories(kcal):", value: String(calorieAverage), standard: "2600"))
        reportList.append(ReportEntity(name: "Average Carbs(g):", value: String(carbohydrateAverage), standard: "300"))
        reportList.append(ReportEntity(name: "Average Protein(g):", value: String(proteinAverage), standard: "100"))
        reportList.append(ReportEntity(name: "Average Fat(g):", value: String(fatAverage), standard: "100"))
        reportTableView.reloadData()
    }

    @IBAction func onBackPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension ReportChartViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reportList.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "reportCell") as? ReportTableCell {
            cell.setupReportCell(reportLabel: reportList[indexPath.row].name, ReportValue: reportList[indexPath.row].value, ReportStandard: reportList[indexPath.row].standard)
            return cell
        } else {
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)
        switch reportList[indexPath.row].name {
        case "Average Calories(kcal):":
            setUpData(type: "calorie")
            graphView.reload()
            lineLabel.text = "calorie"
        case "Average Carbs(g):":
            setUpData(type: "carbo")
            graphView.reload()
            lineLabel.text = "Carbohydrate"
        case "Average Protein(g):":
            setUpData(type: "protein")
            graphView.reload()
            lineLabel.text = "protein"
        case "Average Fat(g):":
            setUpData(type: "fat")
            graphView.reload()
             lineLabel.text = "fat"
        default:
            break
        }

    }

}

extension ReportChartViewController: ScrollableGraphViewDataSource {

    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        // Return the data for each plot.
        switch plot.identifier {
        case "line":
//            return Array(graphDataDict.values)[pointIndex]
            return graphDataDict[graphDataSortedKeys[pointIndex]]!
        default:
            return 0
        }
    }

    func label(atIndex pointIndex: Int) -> String {
//        let result = String(Array(graphDataDict.keys)[pointIndex].prefix(7))
        let result = graphDataSortedKeys[pointIndex].prefix(7)
        return String(result)
    }

    func numberOfPoints() -> Int {
        return graphDataDict.count
    }
}
