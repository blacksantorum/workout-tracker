//
//  ViewController.swift
//  Workout Tracker
//
//  Created by Chris Tibbs on 12/16/18.
//  Copyright © 2018 Chris Tibbs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  let users = ["Chris", "Emily"]
  let userIdKey = "userId"
  var userId: String? {
    get {
      return UserDefaults.standard.value(forKey: userIdKey) as? String
    }
    set {
      UserDefaults.standard.set(newValue, forKey: userIdKey)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  override func viewWillAppear(_ animated: Bool) {
    if userId == nil {
      showUserPicker()
    }
  }

  fileprivate func showUserPicker() {
    let userPickerAlert = UIAlertController(title: "Choose user",
                                            message: "What's your name?",
                                            preferredStyle: .actionSheet)
    for user in users {
      userPickerAlert.addAction(UIAlertAction(title: user,
                                              style: .default,
                                              handler: { [weak self] (action) in
        self?.userId = action.title
      }))
    }
    present(userPickerAlert, animated: true, completion: nil)
  }
}

