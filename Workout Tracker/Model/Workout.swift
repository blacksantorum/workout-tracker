//
//  Workout.swift
//  Workout Tracker
//
//  Created by Chris Tibbs on 12/16/18.
//  Copyright © 2018 Chris Tibbs. All rights reserved.
//

import Foundation

class Workout: Codable {
  var date: Date
  var desc: String
  // Chris or Emily
  var userId: String
  
  init?(dictionary: [String: Any]) {
    if let dateInterval = dictionary["date"] as? TimeInterval,
      let description = dictionary["desc"] as? String,
      let userId = dictionary["userId"] as? String {
      self.date = Date(timeIntervalSince1970: dateInterval)
      self.desc = description
      self.userId = userId
    } else {
      return nil
    }
  }
}
