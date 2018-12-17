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
  
  fileprivate func dateStringForFormat(_ format: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.string(from: currentDate)
  }
  
  fileprivate var currentDate: Date
  fileprivate var daysUntilEndOfWeek: Int
  fileprivate var workouts: [Workout]
  
  init(currentDate: Date, daysUntilEndOfWeek: Int, workouts: [Workout]) {
    self.currentDate = currentDate
    self.daysUntilEndOfWeek = daysUntilEndOfWeek
    self.workouts = workouts
  }
  
  func progressBar(for user: String) -> ProgressBar {
    let workoutsForUser = workouts.filter { $0.userId == user }.count
    // How many days are left minus the amount of workouts the user needs.
    let allowedOffDays = daysUntilEndOfWeek - (goalWorkoutDays - workoutsForUser)
    
    var progressBarColor = UIColor.clear
    if allowedOffDays > 0 {
      progressBarColor = UIColor.green
    } else if allowedOffDays == 0 {
      progressBarColor = UIColor.yellow
    } else {
      progressBarColor = UIColor.red
    }
    
    return ProgressBar(bars: workoutsForUser, progressColor: progressBarColor)
  }
  
  func progressText(for user: String) -> String {
    let workoutsForUser = workouts.filter { $0.userId == user }.count
    return "(\(workoutsForUser)/\(goalWorkoutDays)"
  }
}
