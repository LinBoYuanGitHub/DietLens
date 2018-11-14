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
        static let stepCounterText = "StepCounter"
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
        static let exerciseDescriptionArr = ["Occupations that do not require much physical effort, almost no exercise", "Desk job with requirements to move occasionlly, little to no exericise", "Non-strenuous occaupations with frequent exercise", "Strenuous work of frequent leisure exercise for serveral hours a day", "Physically demanding occupations such as competitive athletes"]

    }

    struct FireBaseAnalytic {
        static let CaptureButtonPressed = "on_click_capture"
        static let OpenCameraView = "on_click_camera"
        static let RecogCategorySelect = "on_click_cat"
        static let RecogItemSelect = "on_click_item"
        static let RecogItemSave = "on_click_save"
    }

    struct GenderText {
        static let MALE = "Male"
        static let FEMALE = "Female"
    }

    struct EnthnicityText {
        static let CHINESE = "Chinese"
        static let MALAYS = "Malays"
        static let INDIANS = "Indians"
        static let OTHER = "Other"
    }

    struct ThresholdValue {
        static let introductionOffsetThreshold = 900
    }

    struct DefaultValue {
        static let BIRTHDAYDEFAULT = "01-07-1990"
    }

    struct ScreenName {
        static let HomePageView = "HomePage"
        static let NotificationPageView = "NotificationPage"
        static let HomeNutritionInfoView = "HomeNutritionInfo"
        static let LatestArticlesView = "LatestArticles"
        static let LatestEventsView = "LatestEvents"
        static let FoodDiaryPageView = "FoodDiaryPage"
        static let HealthLogPageView = "HealthLogPage"
        static let HealthLogStepCounterView = "HealthLogStepCounter"
        static let HealthLogWeightView = "HealthLogWeight"
        static let HealthLogBloodGlucoseView = "HealthLogBloodGlucose"
        static let HealthLogMoodView = "HealthLogMood"
        static let MorePageView = "MorePage"
        static let MoreFeedbackView = "MoreFeedback"
        static let MoreEditProfile = "MoreEditProfile"
        static let CameraPageView = "AddFoodByImage"
        static let TextSearchPageView = "AddFoodByTextPopular"
    }

    struct DateString {
        static let weekString =  ["Mon", "Tues", "Wed", "Thur", "Fri", "Sat", "Sun"]
        static let monthString = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    }

    enum DateMode {
        case day
        case week
        case month
        case year
    }

}
