//
//  StringConstants.swift
//  DietLens
//
//  Created by linby on 26/02/2018.
//  Copyright © 2018 NExT++. All rights reserved.
//

import Foundation

struct StringConstants {
    struct UIString {
        static let IngredientHeaderText = "Ingredients (per serve)"
        static let NutritionHeaderText = "Nutrients "
        static let diaryIngredientUnit = "g"
        static let calorieUnit = "kcal"
        static let updateBtnText = "Update"
        static let addBtnText = "Done"
        static let saveBtnText = "Save"
    }
    struct MealString {
        static let breakfast = "Breakfast"
        static let lunch = "Lunch"
        static let dinner = "Dinner"
        static let snack = "Snack"
    }

    struct NavigatorTitle {
        static let reportTitle = "Report"
        static let dietlensTitle = "Dietlens"
    }

    struct ErrMsg {
        static let loginErrMsg = "Email or password is incorrect"
        static let noInternetErrorMsg = "No Internet Connection..."
    }

    struct ExerciseLvlText {
        static let exerciseLvlArr = ["SEDENTARY", "LIGHTLY ACTIVE", "ACTIVE", "VERY ACTIVE", "EXTERMELY ACTIVE"]
        static let exerciseFrequencyArr = ["none", "Once per week", "Twice per week", "Once per day", "Twice per day"]
        static let exerciseDescriptionArr = ["Occupations that do not require much physical effort, almost no exercise", "Desk job with requirements to move occasionlly, little to no exericise", "Non_strenuous occaupations with frequent exercise", "Strenuous work of frequent leisure exercise for serveral hours a day", "Physically demanding occupations such as competitive athletes"]

    }

    struct ThresholdValue {
        static let introductionOffsetThreshold = 900
    }

}
