//
//  DateUtils.swift
//  Workout Tracker
//
//  Created by Chris Tibbs on 12/29/18.
//  Copyright © 2018 Chris Tibbs. All rights reserved.
//

import UIKit

class DateUtils: NSObject {
  static var PSTCalendar: Calendar {
    var calendar = Calendar.current
    guard let pacificTimeZone = TimeZone(abbreviation: "PST") else {
      assertionFailure("Inaccurate time zone")
      return Calendar.current
    }
    calendar.timeZone = pacificTimeZone
    return calendar
  }
  
  static var startOfWeek: Date {
    return PSTCalendar.date(from: PSTCalendar.dateComponents([.yearForWeekOfYear, .weekOfYear],
                                                             from: Date()))!
  }
  
  static var endOfWeek: Date {
    return startOfWeek.addingTimeInterval((60 * 60 * 24 * 7) - 1)
  }
}
