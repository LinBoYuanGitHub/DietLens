//
//  DairyDailyModel.swift
//  DietLens
//
//  Created by next on 7/11/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

public enum Meal: Int
{
    case Breakfast
    case Lunch
    case Dinner
}

struct DiaryDailyFood
{
    var mealOfDay: Meal = .Breakfast
    
}
