//
//  SplashScreenViewController.swift
//  DietLens
//
//  Created by next on 6/12/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit
import HealthKit

class SplashScreenViewController: UIViewController {

    let articleDatamanager = ArticleDataManager.instance

    var healthStore: HKHealthStore?

    override func viewDidLoad() {
        super.viewDidLoad()
        APIService.instance.getArticleList { (articleList) in
            if articleList != nil {
                self.articleDatamanager.articleList = articleList!
            }
        }
        let preferences = UserDefaults.standard
        let key = "userId"
        var userId = preferences.object(forKey: key)
        if userId == nil {
            APIService.instance.getUUIDRequest { (_) in
                DispatchQueue.main.async {
                     self.performSegue(withIdentifier: "toMainPage", sender: self)
                }
            }
        } else {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toMainPage", sender: self)
            }
        }
        // Do any additional setup after loading the view.
    }

    func loadSteps() {
        healthStore = HKHealthStore()

        // Query to get the user's latest weight, if it exists.
        let stepsCompletion: (([Double], Error?) -> Void) = {

            (totalStepsForDay, error) -> Void in

            if let error = error {
                self.displayAlert(for: error)
            } else {
                print ("totalStepsForDay:\(totalStepsForDay)")
            }

        }

        if let healthStore = self.healthStore {
            healthStore.getStepsForWeekGivenDate(anyDayOfTheWeek: Date(), completion: stepsCompletion)
        }
    }

    func displayAlert(for error: Error) {

        let alert = UIAlertController(title: nil,
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "O.K.",
                                      style: .default,
                                      handler: nil))

        print("Error with healthkit \(error.localizedDescription)")
        present(alert, animated: true, completion: nil)
    }

    func loadWorkouts(completion: @escaping (([HKWorkout]?, Error?) -> Swift.Void)) {

        //1. Get all workouts with the "Other" activity type.
        let workoutPredicate = HKQuery.predicateForWorkouts(with: .walking)

        //2. Get all workouts that only came from this app.
        //let sourcePredicate = HKQuery.predicateForObjects(from: HKSource.default())

        //3. Combine the predicates into a single predicate.
        //let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [workoutPredicate,
                                                                           //sourcePredicate])

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate,
                                              ascending: true)

        let query = HKSampleQuery(sampleType: HKObjectType.workoutType(),
                                  predicate: workoutPredicate,
                                  limit: 0,
                                  sortDescriptors: [sortDescriptor]) { (_, samples, error) in

                                    DispatchQueue.main.async {

                                        //4. Cast the samples as HKWorkout
                                        guard let samples = samples as? [HKWorkout],
                                            error == nil else {
                                                completion(nil, error)
                                                return
                                        }

                                        completion(samples, nil)
                                    }
        }

        HKHealthStore().execute(query)
    }

    func getAgeSexAndBloodType() throws -> (age: Int,
        biologicalSex: HKBiologicalSex,
        bloodType: HKBloodType) {

            let healthKitStore = HKHealthStore()

            do {

                //1. This method throws an error if these data are not available.
                let birthdayComponents =  try healthKitStore.dateOfBirthComponents()
                let biologicalSex =       try healthKitStore.biologicalSex()
                let bloodType =           try healthKitStore.bloodType()

                //2. Use Calendar to calculate age.
                let today = Date()
                let calendar = Calendar.current
                let todayDateComponents = calendar.dateComponents([.year],
                                                                  from: today)
                let thisYear = todayDateComponents.year!
                let age = thisYear - birthdayComponents.year!

                //3. Unwrap the wrappers to get the underlying enum values.
                let unwrappedBiologicalSex = biologicalSex.biologicalSex
                let unwrappedBloodType = bloodType.bloodType

                return (age, unwrappedBiologicalSex, unwrappedBloodType)
            }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? HomeViewController {

        }
    }

}
