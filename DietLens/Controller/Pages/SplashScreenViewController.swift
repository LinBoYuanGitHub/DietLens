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

    var healthStore: HKHealthStore?

    override func viewDidLoad() {
        super.viewDidLoad()
        let preferences = UserDefaults.standard
        let token = preferences.string(forKey: PreferenceKey.tokenKey)
        if token == nil {
            //redirect to login page
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toLoginPage", sender: self)
            }
        } else {
            //redirect to home page
            getArticleListToMainPage()
            loadNutritionTarget()
        }
//        APIService.instance.getUUIDRequest(userId: userId!) { (userId) in
//            let preferences = UserDefaults.standard
//            let key = "userId"
//            preferences.setValue(userId, forKey: key)
//            let didSave = preferences.synchronize()
//            if !didSave {
//                print("Couldn`t save,fatal exception happened")
//            } else {
//                print("userId:\(userId)")
//            }
//            //send notification to server
//            let tokenKey = "fcmToken"
//            let token = preferences.string(forKey: tokenKey)
//            if token != nil {
//                //send token to server
//                APIService.instance.saveDeviceToken(uuid: userId, fcmToken: token!, status: "True", completion: { (flag) in
//                    if flag {
//                        preferences.setValue(nil, forKey: tokenKey)
//                        print("send device token succeed")
//                    }
//                })
//            }
//            self.getArticleListToMainPage()
//        }

        // Do any additional setup after loading the view.
    }

    func getArticleListToMainPage() {
        APIService.instance.getArticleList { (articleList) in
            if articleList != nil {
                APIService.instance.getEventList { (_) in
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "toMainPage", sender: self)
                    }
                }
            } else {
                //TODO: handle article list nil
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toMainPage", sender: self)
                }
            }
        }
    }

    func loadNutritionTarget() {
        APIService.instance.getDietaryGuideInfo { (guideDict) in
            let preferences = UserDefaults.standard
            preferences.setValue(guideDict["energy"], forKey: PreferenceKey.calorieTarget)
            preferences.setValue(guideDict["carbohydrate"], forKey: PreferenceKey.carbohydrateTarget)
            preferences.setValue(guideDict["protein"], forKey: PreferenceKey.proteinTarget)
            preferences.setValue(guideDict["fat"], forKey: PreferenceKey.fatTarget)
        }
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
