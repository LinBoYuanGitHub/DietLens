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
        static let moreBtnText = "More"
        static let stepCounterText = "StepCounter"
        //menu action item
        static let addFavActionItem = "Favourite"
        static let removeFavActionItem = "Unfavourite"
        static let deleteActionItem = "Delete"
        //textSearch filter tab
        static let FitlerPopular = "Popular"
        static let FilterRecent = "Recent"
        static let FilterFavorite = "Favourite"
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
        static let exerciseLvlArr = ["Sedentary", "Lightly Active", "Active", "Very Active", "Extremely Active"]
        static let exerciseFrequencyArr = ["none", "Once per week", "Twice per week", "Once per day", "Twice per day"]
        static let exerciseDescriptionArr = ["Occupations that require little physical effort, i.e. almost never exercise.", "Occupations that feature occasional movement, i.e. rarely exercise.", "Non-strenuous occupations with frequent movement, i.e. occasionally exercise.", "Strenuous work featuring exercise for several hours a day, i.e. frequent exercise.", "Physically demanding occupations, i.e. very frequent exercise."]

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
