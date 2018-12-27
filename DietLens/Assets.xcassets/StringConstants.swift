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
        static let nextBtnText = "Next"
        static let stepCounterText = "StepCounter"
        //menu action item
        static let addFavActionItem = "Favourite"
        static let removeFavActionItem = "Unfavourite"
        static let deleteActionItem = "Delete"
        //textSearch filter tab
        static let FitlerPopular = "Popular"
        static let FilterRecent = "Recent"
        static let FilterFavorite = "Favourite"
        //SMS verfication code sending
        static let SMSCodeSendingText = "Get Code"
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
        //click
        static let HomeClickCameraButton = "home_click_camera_button"
        static let FoodDiaryClickAddButton = "food_diary_click_add_button"
        static let ImageClickCaptureButton = "image_click_capture_button"
        static let ImageClickGalleryButton = "image_click_gallery_button"
        static let ImageClickByTextTab = "image_click_by_text_tab"
        static let TextClickByImageTab = "text_click_by_image_tab"
        static let ImageResultClickSearchMoreButton = "image_result_click_search_more_button"
        static let FoodPageAddSaveButton = "add_food_click_save_button"
        static let RecogCategorySelect = "on_click_cat"
        static let RecogItemSelect = "on_click_item"
        //scroll
        static let TextResultScrollFoodItem = "text_result_scroll_food_item"
        static let ImageResultScrollFoodItem = "image_result_scroll_food_item"
        static let ImageResultScrollFoodCategory = "image_result_scroll_food_category"
        //select item
        static let ImageResultSelectFoodItem = "image_result_select_food_item"
        static let TextResultSelectFoodItem = "text_result_select_food_item"
        static let ImageSelectSampleItem = "image_select_sample_item"
        //back event
        static let ImageClickBack = "image_click_back"
        static let ImageResultBack = "image_result_click_back"
        static let FoodItemClickBack = "food_item_click_back"
        static let FoodListClickBack = "food_list_click_back"
        static let SearchMoreClickBack = "search_more_click_back"
        static let TextClickBack = "text_click_back"
        //total flag event
        static let FoodRecrodStartFlag = "food_search_flag"
        //image flag event
        static let ImageCaptureFlag = "image_capture_flag"
        static let ImageSelectFlag = "image_select_flag"
        static let imageAddFlag = "image_add_flag"
        //text search flag event
        static let TextViewFlag = "text_view_flag"
        static let TextSelectFlag = "text_select_flag"
        static let TextAddFlag = "text_add_flag"
        //text search more event
        static let SearchMoreFlag = "search_more_flag"
        static let SearchMoreSelectFlag = "search_more_select_flag"
        static let SearchMoreAddFlag = "search_more_add_flag"
        //app quit & resume
        static let Quit = "app_quit"
        static let Resume = "app_resume"

        struct Parameter {
            static let MealTime = "meal_time"
            static let recordType = "record_type"
            static let Rank = "rank"
            static let OS = "platform"
        }
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

    static let whiteDomainList  = ["https://download.dietlens.com", "https://www.dietlens.com"]
    struct IodineLevel {

        static let text = ["Safe to eat: low/no iodine", "We have not found the iodine level for this food. It is likely that it has a low or negligible iodine level, however, you may want to contact your healthcare provider.", "Not suitable to eat: significant iodine content"]
        static let icon = ["iodine_ok_icon", "iodine_unknown_icon", "iodine_warning_icon"]
        static let color = [0x80bd57, 0xe25d5f, 0xea2040]
    }

    enum DateMode {
        case day
        case week
        case month
        case year
    }

}
