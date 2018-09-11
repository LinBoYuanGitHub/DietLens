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
        static let exerciseLvlArr = ["none", "Light exercise", "Moderate exercise", "Heavy exercise", "Vigorous exercise"]
        static let exerciseFrequencyArr = ["none", "Once per week", "Twice per week", "Once per day", "Twice per day"]
        static let exerciseDescriptionArr = ["none", "Intensive exercise for at least 20 minutes 1 to 3 times per week e.g. cycling, jogging, basketball, swimming, skating, etc. If you do not exercise regularly, but you maintain a busy life style that requires you to walk frequently for long periods, you meet the requirements of this level", "Intensive exercise for at least 30 to 60 minutes 3 to 4 times per week", "Intensive exercise for 60 minutes or greater 5 to 7 days per week.  Labor-intensive occupations also qualify for this level e.g. construction work (brick laying, carpentry, general labor etc). Also farming, landscape worker or similar occupations", "Exceedingly active and/or very demanding activities e.g. athlete with an almost unstoppable training schedule with multiple training sessions throughout the day or people with very demanding jobs such as shoveling coal or working long hours on an assembly line."]

    }

    struct ThresholdValue {
        static let introductionOffsetThreshold = 900
    }

}
