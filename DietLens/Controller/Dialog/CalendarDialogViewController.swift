//
//  CalendarDialogViewController.swift
//  DietLens
//
//  Created by linby on 2018/6/21.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
import FSCalendar

protocol CalendarAlertDelegate: class {
    func onCalendarDateSelected(selectedDate: Date)
    func onCalendarCurrentPageDidChange(changedDate: Date)
}

class CalendarDialogViewController: UIViewController, UIPopoverControllerDelegate {
    @IBOutlet weak var diaryCalendar: DiaryDatePicker!
    weak var calendarDelegate: CalendarAlertDelegate?
    var datesWithEvent = [Date]()

    override func viewDidLoad() {
        super.viewDidLoad()
        diaryCalendar.setCurrentPage(Date(), animated: true)
        diaryCalendar.dataSource = self
        diaryCalendar.delegate = self
        //diary style setting
        diaryCalendar.appearance.headerTitleColor = UIColor.black
        diaryCalendar.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        setupView()
    }

    func setupView() {
        self.view.backgroundColor = UIColor.clear
        self.view.isOpaque = false
    }

    func setCurrentPage(selectedDate: Date) {
        diaryCalendar.setCurrentPage(selectedDate, animated: true)
    }

    func setDelegate(delegate: CalendarAlertDelegate) {
        self.calendarDelegate = delegate
    }

    func dismissDialog() {
        self.dismiss(animated: true, completion: nil)
    }

    func getAvailableDate(year: String, month: String) {
        APIService.instance.getAvailableDate(year: year, month: month) { (dateList) in
            //mark redDot for this date
            if dateList != nil {
                self.datesWithEvent = dateList!
            }
            if self.diaryCalendar != nil {
                self.diaryCalendar.reloadData()
            }
        }
    }

}

extension CalendarDialogViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        let currentMonth = DateUtil.formatMonthToString(date: calendar.currentPage)
        if DateUtil.formatMonthToString(date: date) == currentMonth {
            return #colorLiteral(red: 0.2319577109, green: 0.2320933503, blue: 0.2404021281, alpha: 1)
        }
        return #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    }

    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        for dateWithEvent in datesWithEvent {
            if Calendar.current.isDate(date, inSameDayAs: dateWithEvent) {
                return 1
            }
        }
        return 0
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if calendarDelegate != nil {
            calendarDelegate?.onCalendarDateSelected(selectedDate: date)
            if monthPosition == .previous || monthPosition == .next {
                calendar.setCurrentPage(date, animated: true)
            }
        }
    }

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        return #colorLiteral(red: 0.9961311221, green: 0.3479750156, blue: 0.3537038565, alpha: 1)
    }

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        if Calendar.current.isDate(Date(), inSameDayAs: date) {
            return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        return nil
    }

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderDefaultColorFor date: Date) -> UIColor? {
        if Calendar.current.isDate(Date(), inSameDayAs: date) {
            return #colorLiteral(red: 0.9961311221, green: 0.3479750156, blue: 0.3537038565, alpha: 1)
        }
        return nil
    }

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        return [#colorLiteral(red: 0.9961311221, green: 0.3479750156, blue: 0.3537038565, alpha: 1)]
    }

    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let dateStr = DateUtil.normalDateToString(date: calendar.currentPage)
        getAvailableDate(year: dateStr.components(separatedBy: "-")[0], month: dateStr.components(separatedBy: "-")[1])
        if calendarDelegate != nil {
            calendarDelegate?.onCalendarCurrentPageDidChange(changedDate: calendar.currentPage)
        }
    }
}
