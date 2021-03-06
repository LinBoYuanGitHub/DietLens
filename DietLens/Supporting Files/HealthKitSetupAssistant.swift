//
//  HealthKitSetupAssistant.swift
//  DietLens
//
//  Created by next on 14/12/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation
import HealthKit

class HealthKitSetupAssistant {

    private enum HealthkitSetupError: Error {
        case notAvailableOnDevice
        case dataTypeNotAvailable
    }

    class func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HealthkitSetupError.notAvailableOnDevice)
            return
        }

        guard let steps = HKObjectType.quantityType(forIdentifier: .stepCount) else {

                completion(false, HealthkitSetupError.dataTypeNotAvailable)
                return
        }

//        let healthKitTypesToWrite: Set<HKSampleType> = [bodyMassIndex,
//                                                        activeEnergy,
//                                                        steps,
//                                                        HKObjectType.workoutType()]

        let healthKitTypesToWrite: Set<HKSampleType> = []
        let healthKitTypesToRead: Set<HKObjectType> = [steps]

        HKHealthStore().requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { (success, error) in
                                                completion(success, error)
        }
    }
}

typealias HKCompletionHandle = ((HKQuantity?, Error?) -> Void)
typealias HKCompletionHandleDouble = ((Double, Error?) -> Void)

extension HKHealthStore {

    func getStepsForToday(completion completionHandler: ((Double, Error?) -> Void)?) {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: Date())
        let endDate: Date = calendar.date(byAdding: Calendar.Component.day, value: 1, to: startDate)!

        let predicate: NSPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions.strictStartDate)

        let completionHandler: (HKStatisticsQuery, HKStatistics?, Error?) -> Void = {
            (_, result, error) -> Void in

            let sum: HKQuantity? = result!.sumQuantity()

            if completionHandler != nil {
                let value: Double = (sum != nil) ? sum!.doubleValue(for: HKUnit.count()) : 0

                completionHandler!(value, error)
            }
        }

        let query = HKStatisticsQuery(quantityType: HKQuantityType.quantityType(forIdentifier: .stepCount)!, quantitySamplePredicate: predicate, options: HKStatisticsOptions.cumulativeSum, completionHandler: completionHandler)
        self.execute(query)
    }

    func getStepsForDate(stepsCountForDate date: Date, completion completionHandler: ((Double, Error?) -> Void)?) {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date)
        let endDate: Date = calendar.date(byAdding: Calendar.Component.day, value: 1, to: startDate)!

        let predicate: NSPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions.strictStartDate)

        let completionHandler: (HKStatisticsQuery, HKStatistics?, Error?) -> Void = {
            (_, result, error) -> Void in

            let sum: HKQuantity? = result!.sumQuantity()

            if completionHandler != nil {
                let value: Double = (sum != nil) ? sum!.doubleValue(for: HKUnit.count()) : 0

                completionHandler!(value, error)
            }
        }

        let query = HKStatisticsQuery(
            quantityType: HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            quantitySamplePredicate: predicate, options: HKStatisticsOptions.cumulativeSum, completionHandler: completionHandler)

        self.execute(query)
    }

    func getStepsForWeekGivenDate(anyDayOfTheWeek date: Date, completion completionHandler: (([Double], Error?) -> Void)?) {
        let calendar = Calendar.current

        var comp = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: date)
        comp.weekday = 2 // Monday, 1 is Sunday, 0 is Sat
        let startDate = calendar.startOfDay(for: calendar.date(from: comp)!)
        let endOfWeekDate = calendar.date(byAdding: .day, value: 6, to: startDate)!

        let today = calendar.date(byAdding: Calendar.Component.day, value: 1, to: Date())!
        var endDate: Date
        if endOfWeekDate > today {
            endDate = calendar.date(byAdding: Calendar.Component.day, value: 1, to: Date())!
        } else {
            endDate = calendar.date(byAdding: Calendar.Component.day, value: 1, to: endOfWeekDate)!
        }

        let predicate: NSPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions.strictStartDate)

        let completionHandler: (HKSampleQuery, [HKSample]?, Error?) -> Void = {
            (_, results, error) -> Void in
            var steps = [Double]()
            if results!.count > 0, let samples = results as? [HKQuantitySample] {
                for result in samples {
                    steps.append(result.quantity.doubleValue(for: HKUnit.count()))
                }
            }
            if completionHandler != nil {
                completionHandler!(steps, error)
            }
        }
        let query = HKSampleQuery(sampleType: HKQuantityType.quantityType(forIdentifier: .stepCount)!, predicate: predicate, limit: 0, sortDescriptors: nil, resultsHandler: completionHandler)
        self.execute(query)
    }

    func getHourlyStepsCountList(completion completionHandler: (([StepEntity], Error?) -> Void)?) {
        getHourlyStepsCountList(inputDate: Date(), completion: completionHandler)
    }

    func getHourlyStepsCountList(inputDate: Date, completion completionHandler: (([StepEntity], Error?) -> Void)?) {
        let calendar = Calendar.current
        var interval = DateComponents()
        interval.hour = 1
        var anchorComponents = calendar.dateComponents([.hour, .day, .month, .year], from: inputDate)
        anchorComponents.hour = 0
        guard let anchorDate = calendar.date(from: anchorComponents) else {
            fatalError("*** unable to create a valid date from the given components ***")
        }
        guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount) else {
            fatalError("*** Unable to create a step count type ***")
        }
        // Create the query
        let query = HKStatisticsCollectionQuery(quantityType: quantityType,
                                                quantitySamplePredicate: nil,
                                                options: .cumulativeSum,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)
        // Set the results handler
        query.initialResultsHandler = {
            query, results, error in

            guard let statsCollection = results else {
                // Perform proper error handling here
                if completionHandler != nil {
                    completionHandler!([], error)
                }
                return
            }
            let components = calendar.dateComponents([.hour, .day, .month, .year], from: inputDate)
//            components.timeZone = TimeZone(secondsFromGMT: 0)
            let startDate = calendar.date(from: components)
            guard let endDate = calendar.date(byAdding: .day, value: 1, to: startDate!)
                else {
                    if completionHandler != nil {
                        completionHandler!([], error)
                    }
                    return
            }
            var stepList = [StepEntity]()
            // Plot the weekly step counts over the past 3 months
            statsCollection.enumerateStatistics(from: startDate!, to: endDate) { statistics, _ in

                let date = statistics.startDate
                if let quantity = statistics.sumQuantity() {
                    let value = quantity.doubleValue(for: HKUnit.count())
                    let stepEntity = StepEntity(date: date, stepValue: value)
                    // Call a custom method to plot each data point.
                    stepList.append(stepEntity)
                } else {
                    let stepEntity = StepEntity(date: date, stepValue: 0)
                    stepList.append(stepEntity)
                }
            }
            completionHandler!(stepList, error)
        }
        self.execute(query)
    }

    func getWeeklyStepsCountList(anyDayOfTheWeek date: Date, completion completionHandler: (([StepEntity], Error?) -> Void)?) {
        let calendar = Calendar.current
        var interval = DateComponents()
        interval.day = 1
        var anchorComponents = calendar.dateComponents([.day, .month, .year, .weekday], from: Date())
        anchorComponents.hour = 0
        guard let anchorDate = calendar.date(from: anchorComponents) else {
            return
        }
        guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount) else {
            return
        }
        // Create the query
        let query = HKStatisticsCollectionQuery(quantityType: quantityType,
                                                quantitySamplePredicate: nil,
                                                options: .cumulativeSum,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)
        // Set the results handler
        query.initialResultsHandler = {
            query, results, error in

            guard let statsCollection = results else {
                // Perform proper error handling here
                if completionHandler != nil {
                    completionHandler!([], error)
                }
                return
            }
            var stepList = [StepEntity]()
            // Plot the weekly step counts over the past 3 months
            statsCollection.enumerateStatistics(from: date.beginOfWeek!, to: date.endOfWeek!) { statistics, _ in

                if let quantity = statistics.sumQuantity() {
                    let date = statistics.startDate
                    let value = quantity.doubleValue(for: HKUnit.count())
                    let stepEntity = StepEntity(date: date, stepValue: value)
                    // Call a custom method to plot each data point.
                    stepList.append(stepEntity)
                }
            }
            completionHandler!(stepList, error)
        }
        self.execute(query)
    }

    /**
    get monthly data strat from the first day of current month to today
    **/
    func getMonthlyStepsCountList(anyDayOfMonth date: Date, completion completionHandler: (([StepEntity], Error?) -> Void)?) {
        let calendar = Calendar.current
        var interval = DateComponents()
        interval.day = 1
        var anchorComponents = calendar.dateComponents([.day, .month, .year], from: Date())
        anchorComponents.hour = 0
        guard let anchorDate = calendar.date(from: anchorComponents) else {
            fatalError("*** unable to create a valid date from the given components ***")
        }
        guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount) else {
            fatalError("*** Unable to create a step count type ***")
        }
        // Create the query
        let query = HKStatisticsCollectionQuery(quantityType: quantityType,
                                                quantitySamplePredicate: nil,
                                                options: .cumulativeSum,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)
        // Set the results handler
        query.initialResultsHandler = {
            query, results, error in

            guard let statsCollection = results else {
                // Perform proper error handling here
                if completionHandler != nil {
                    completionHandler!([], error)
                }
                return
            }
            let components = calendar.dateComponents([.month, .year ], from: date)
            let startOfMonth = calendar.date(from: components)
            var comps2 = DateComponents()
            comps2.month = 1
            comps2.day = -1
            let endOfMonth = calendar.date(byAdding: comps2, to: startOfMonth!)
            var stepList = [StepEntity]()
            // Plot the weekly step counts over the past 3 months
            statsCollection.enumerateStatistics(from: startOfMonth!, to: endOfMonth!) { statistics, _ in

                if let quantity = statistics.sumQuantity() {
                    let date = statistics.startDate
                    let value = quantity.doubleValue(for: HKUnit.count())
                    let stepEntity = StepEntity(date: date, stepValue: value)
                    // Call a custom method to plot each data point.
                    stepList.append(stepEntity)
                }
            }
            completionHandler!(stepList, error)
        }
        self.execute(query)
    }

    func getYearlyStepsCounterList(anyDayOfYear date: Date, completion completionHandler: (([StepEntity], Error?) -> Void)?) {
        var calendar = Calendar.current
        var interval = DateComponents()
        interval.month = 1
        var anchorComponents = calendar.dateComponents([.month, .year], from: Date())
        anchorComponents.hour = 0
        guard let anchorDate = calendar.date(from: anchorComponents) else {
            fatalError("*** unable to create a valid date from the given components ***")
        }
        guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount) else {
            fatalError("*** Unable to create a step count type ***")
        }
        // Create the query
        let query = HKStatisticsCollectionQuery(quantityType: quantityType,
                                                quantitySamplePredicate: nil,
                                                options: .cumulativeSum,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)
        // Set the results handler
        query.initialResultsHandler = {
            query, results, error in

            guard let statsCollection = results else {
                // Perform proper error handling here
                if completionHandler != nil {
                    completionHandler!([], error)
                }
                return
            }
            let components = calendar.dateComponents([.year], from: date)
            let startOfYear = calendar.date(from: components)
            var comps2 = DateComponents()
            comps2.year = 1
            comps2.month = -1
            let endOfYear = calendar.date(byAdding: comps2, to: startOfYear!)
            var stepList = [StepEntity]()
            // Plot the weekly step counts over the past 3 months
            statsCollection.enumerateStatistics(from: startOfYear!, to: endOfYear!) { statistics, _ in

                if let quantity = statistics.sumQuantity() {
                    let date = statistics.startDate
                    let value = quantity.doubleValue(for: HKUnit.count())
                    let stepEntity = StepEntity(date: date, stepValue: value)
                    // Call a custom method to plot each data point.
                    stepList.append(stepEntity)
                }
            }
            completionHandler!(stepList, error)
        }
        self.execute(query)
    }

}

extension Calendar {
    static let gregorian = Calendar(identifier: .gregorian)
}
extension Date {
    var startOfWeek: Date? {
        return Calendar.gregorian.date(from: Calendar.gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
    }
}
