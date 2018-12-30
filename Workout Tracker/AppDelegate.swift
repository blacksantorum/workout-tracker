//
//  AppDelegate.swift
//  Workout Tracker
//
//  Created by Chris Tibbs on 12/16/18.
//  Copyright © 2018 Chris Tibbs. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()
    return true
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    guard let viewController = window?.rootViewController as? ViewController else {
      assertionFailure("Root view controller isn't a ViewController")
      return
    }
    viewController.fetchWorkoutsAndUpdateUI()
  }
  
  func applicationSignificantTimeChange(_ application: UIApplication) {
    guard let viewController = window?.rootViewController as? ViewController else {
      assertionFailure("Root view controller isn't a ViewController")
      return
    }
    viewController.fetchWorkoutsAndUpdateUI()
  }
}

