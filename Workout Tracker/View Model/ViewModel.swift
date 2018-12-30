//
//  ViewModel.swift
//  Workout Tracker
//
//  Created by Chris Tibbs on 12/16/18.
//  Copyright © 2018 Chris Tibbs. All rights reserved.
//

import UIKit

class ViewModel {
  struct CheckInButton {
    var enabled: Bool
    var text: String
  }
  
  struct ProgressBar {
    var bars: Int
    var progressColor: UIColor
  }
  
  var monthString: String {
    get {
      return dateStringForFormat("MMM")
    }
  }
  var dayString: String {
    get {
      return dateStringForFormat("d")
    }
  }
  
  fileprivate let goalWorkoutDays = 3
  fileprivate let dayInterval: TimeInterval = 60 * 60 * 24
  
  fileprivate func dateStringForFormat(_ format: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    dateFormatter.timeZone = TimeZone(abbreviation: "PST")
    return dateFormatter.string(from: currentDate)
  }
  
  fileprivate var currentDate: Date
  fileprivate var endOfWeek: Date
  fileprivate var currentUser: String
  
  // Publicly accessible for local check-ins.
  var workouts: [Workout]
  
  init(currentUser: String, currentDate: Date, endOfWeek: Date, workouts: [Workout]) {
    self.currentUser = currentUser
    self.currentDate = currentDate
    self.endOfWeek = endOfWeek
    self.workouts = workouts
  }
  
  func progressBar(for user: String) -> ProgressBar {
    let workoutsForUser = workouts.filter { $0.userId == user }
    // How many days are left minus the amount of workouts the user needs.
    
    var referenceDate = hasAWorkoutToday(workouts: workoutsForUser) ?
      currentDate.addingTimeInterval(dayInterval) : currentDate
    
    var daysUntilEndOfWeek = 0
    while referenceDate.timeIntervalSince1970 < endOfWeek.timeIntervalSince1970 {
      referenceDate = referenceDate.addingTimeInterval(dayInterval)
      daysUntilEndOfWeek += 1
    }
    
    let allowedOffDays = daysUntilEndOfWeek - (goalWorkoutDays - workoutsForUser.count)
    
    var progressBarColor = UIColor.clear
    if allowedOffDays > 0 || workoutsForUser.count >= goalWorkoutDays {
      progressBarColor = UIColor.green
    } else if allowedOffDays == 0 {
      progressBarColor = UIColor.yellow
    } else {
      progressBarColor = UIColor.red
    }
    
    return ProgressBar(bars: workoutsForUser.count, progressColor: progressBarColor)
  }
  
  func progressText(for user: String) -> String {
    let userString = currentUser == user ? "You" : user
    return "\(userString) (\(workoutsForUser(user).count)/\(goalWorkoutDays))"
  }
  
  func checkInButton(for user: String) -> CheckInButton {
    let workoutsForUser = workouts.filter { $0.userId == user }
    let userHasWorkedOutToday = hasAWorkoutToday(workouts: workoutsForUser)
    
    let workedOutTodayEmoji = (user == "Emily") ? "💪🏻" : "💪🏽"
    let reachedGoalEmoji = (user == "Emily") ? "👸🏻" : "🤴🏽"
    
    if workoutsForUser.count >= goalWorkoutDays {
      return CheckInButton(enabled: false, text: "You've reached your goal for this week \(reachedGoalEmoji)")
    } else if userHasWorkedOutToday {
      return CheckInButton(enabled: false, text: "You've already worked out today \(workedOutTodayEmoji)")
    } else {
      return CheckInButton(enabled: true, text: "Check in")
    }
  }
  
  func workoutsForUser(_ userId: String) -> [Workout] {
    return workouts.filter { $0.userId == userId }
  }
  
  func hasAWorkoutToday(workouts: [Workout]) -> Bool {
    let calendar = DateUtils.PSTCalendar
    let currentDateComponents = calendar.dateComponents([.day, .month, .year], from: currentDate)
    for workout in workouts {
      let workoutDateComponents = calendar.dateComponents([.day, .month, .year], from: workout.date)
      if workoutDateComponents.day == currentDateComponents.day &&
        workoutDateComponents.month == currentDateComponents.month &&
        workoutDateComponents.year == currentDateComponents.year {
        return true
      }
    }
    return false
  }
}
