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

        guard let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
              let bloodType = HKObjectType.characteristicType(forIdentifier: .bloodType),
              let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex),
              let bodyMassIndex = HKObjectType.quantityType(forIdentifier: .bodyMassIndex),
              let height = HKObjectType.quantityType(forIdentifier: .height),
              let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass),
              let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
                completion(false, HealthkitSetupError.dataTypeNotAvailable)
                return
        }

        let healthKitTypesToWrite: Set<HKSampleType> = [bodyMassIndex,
                                                        activeEnergy,
                                                        steps,
                                                        HKObjectType.workoutType()]

        let healthKitTypesToRead: Set<HKObjectType> = [dateOfBirth,
                                                       bloodType,
                                                       biologicalSex,
                                                       bodyMassIndex,
                                                       height,
                                                       bodyMass,
                                                       steps,
                                                       HKObjectType.workoutType()]

        HKHealthStore().requestAuthorization(toShare: healthKitTypesToWrite,
                                             read: healthKitTypesToRead) { (success, error) in
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

        let query = HKStatisticsQuery(quantityType: HKQuantityType.quantityType(forIdentifier: .stepCount)!, quantitySamplePredicate: predicate, options: HKStatisticsOptions.cumulativeSum, completionHandler: completionHandler)

        self.execute(query)
    }

    func getStepsForWeekGivenDate(anyDayOfTheWeek date: Date, completion completionHandler: ((Double, Error?) -> Void)?) {
        let calendar = Calendar.current

        var comp = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: date)
        comp.weekday = 3 // Monday, 1 is Sunday, 0 is Sat
        let startDate = calendar.startOfDay(for: calendar.date(from: comp)!)
        let endOfWeekDate = calendar.date(byAdding: .day, value: 6, to: startDate)!

        let today = calendar.date(byAdding: Calendar.Component.day, value: 1, to: Date())!
        var endDate: Date
        if(endOfWeekDate > today) {
            endDate = calendar.date(byAdding: Calendar.Component.day, value: 1, to: Date())!
        } else {
            endDate = calendar.date(byAdding: Calendar.Component.day, value: 1, to: endOfWeekDate)!
        }

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

}

extension Calendar {
    static let gregorian = Calendar(identifier: .gregorian)
}
extension Date {
    var startOfWeek: Date? {
        return Calendar.gregorian.date(from: Calendar.gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
    }
}
