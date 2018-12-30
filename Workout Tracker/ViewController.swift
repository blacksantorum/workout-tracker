//
//  ViewController.swift
//  Workout Tracker
//
//  Created by Chris Tibbs on 12/16/18.
//  Copyright © 2018 Chris Tibbs. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

  @IBOutlet weak var monthLabel: UILabel!
  @IBOutlet weak var dayLabel: UILabel!
  @IBOutlet weak var checkInButton: UIButton!
  
  @IBOutlet weak var yourProgressLabel: UILabel!
  @IBOutlet weak var yourProgressBarOne: UIView!
  @IBOutlet weak var yourProgressBarTwo: UIView!
  @IBOutlet weak var yourProgressBarThree: UIView!
  
  @IBOutlet weak var otherProgressLabel: UILabel!
  @IBOutlet weak var otherProgressBarOne: UIView!
  @IBOutlet weak var otherProgressBarTwo: UIView!
  @IBOutlet weak var otherProgressBarThree: UIView!
  
  fileprivate var yourProgressBars: [UIView] {
    get {
      return [yourProgressBarOne, yourProgressBarTwo, yourProgressBarThree]
    }
  }
  
  fileprivate var otherProgressBars: [UIView] {
    get {
      return [otherProgressBarOne, otherProgressBarTwo, otherProgressBarThree]
    }
  }
  
  fileprivate var database: Firestore!
  
  fileprivate var viewModel: ViewModel?
  fileprivate let users = ["Chris", "Emily"]
  fileprivate let userIdKey = "userId"
  fileprivate var userId: String? {
    get {
      return UserDefaults.standard.value(forKey: userIdKey) as? String
    }
    set {
      UserDefaults.standard.set(newValue, forKey: userIdKey)
    }
  }
  
  fileprivate var lastWeekTimestamp: String {
    get {
      return "\(DateUtils.startOfLastWeek.timeIntervalSince1970)-\(DateUtils.endOfLastWeek.timeIntervalSince1970)"
    }
  }
  
  fileprivate var otherUserId: String {
    guard let userId = userId else {
      assertionFailure("There's no active user")
      return "null"
    }
    return userId == "Chris" ? "Emily" : "Chris"
  }
  
  @IBAction func didTapCheckInButton(_ sender: Any) {
    showWorkoutDetailAlert()
  }
  
  @IBAction func didTapRefreshButton(_ sender: Any) {
    fetchWorkoutsAndUpdateUI()
  }
  
  fileprivate let goalWorkoutDays = 3
  
  override func viewDidLoad() {
    super.viewDidLoad()
    database = Firestore.firestore()
    let settings = database.settings
    settings.areTimestampsInSnapshotsEnabled = true
    database.settings = settings
    
    for bar in yourProgressBars + otherProgressBars {
      bar.layer.cornerRadius = 16
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if userId == nil {
      showUserPicker()
    } else {
      fetchWorkoutsAndUpdateUI()
    }
  }
  
  func fetchWorkoutsAndUpdateUI() {
    guard let userId = userId else {
      // assertionFailure("Calling fetch workouts without a user")
      return
    }
    fetchWorkouts(startDate: DateUtils.startOfWeek, endDate: DateUtils.endOfWeek) { [weak self] (workouts) in
      guard let self = self else {
        assertionFailure("There's no view controller")
        return
      }
      self.viewModel = ViewModel(currentUser: userId,
                                  currentDate: Date(),
                                  endOfWeek: DateUtils.endOfWeek,
                                  workouts: workouts,
                                  goalWorkoutDays: self.goalWorkoutDays)
      self.updateUI()
    }
    
    if !UserDefaults.standard.bool(forKey: lastWeekTimestamp) {
      resolveLastWeek()
    }
  }
  
  fileprivate func resolveLastWeek() {
    fetchWorkouts(startDate: DateUtils.startOfLastWeek,
                  endDate: DateUtils.endOfLastWeek) { [weak self] workouts in
      let chrisWorkoutsCount = workouts.filter { $0.userId == "Chris" }.count
      let emilyWorkoutsCount = workouts.filter { $0.userId == "Emily" }.count
      
      guard let self = self else {
        assertionFailure("There's no view controller")
        return
      }
      
      var event = ""
      if chrisWorkoutsCount >= self.goalWorkoutDays && emilyWorkoutsCount >= self.goalWorkoutDays {
        event = "both_won"
      } else if chrisWorkoutsCount >= self.goalWorkoutDays && emilyWorkoutsCount < self.goalWorkoutDays {
        event = "chris_won"
      } else if chrisWorkoutsCount < self.goalWorkoutDays && emilyWorkoutsCount >= self.goalWorkoutDays {
        event = "emily_won"
      } else if chrisWorkoutsCount <= self.goalWorkoutDays && emilyWorkoutsCount <= self.goalWorkoutDays {
        event = "nobody_won"
      }
                    
      if event.count > 0 {
        Analytics.logEvent(event, parameters: nil)
        UserDefaults.standard.set(true, forKey: self.lastWeekTimestamp)
      }
     }
  }
  
  fileprivate func updateUI() {
    guard let viewModel = viewModel else {
      assertionFailure("View model is nil")
      return
    }
    
    guard let userId = userId else {
      assertionFailure("There's no active user")
      return
    }
    
    monthLabel.text = viewModel.monthString
    dayLabel.text = viewModel.dayString
    
    let checkInButtonInfo = viewModel.checkInButton(for: userId)
    checkInButton.setTitle(checkInButtonInfo.text, for: .normal)
    checkInButton.isEnabled = checkInButtonInfo.enabled
    
    yourProgressLabel.text = viewModel.progressText(for: userId)
    let yourProgressBar = viewModel.progressBar(for: userId)
    updateProgressBars(yourProgressBars,
                       numberOfBars: yourProgressBar.bars,
                       color: yourProgressBar.progressColor)
    
    otherProgressLabel.text = viewModel.progressText(for: otherUserId)
    let otherProgressBar = viewModel.progressBar(for: otherUserId)
    updateProgressBars(otherProgressBars,
                       numberOfBars: otherProgressBar.bars,
                       color: otherProgressBar.progressColor)
  }
  
  fileprivate func updateProgressBars(_ progressBars: [UIView],
                                      numberOfBars: Int,
                                      color: UIColor) {
    for progressBar in progressBars {
      progressBar.backgroundColor = UIColor.clear
    }
    
    var i = 0
    while i < numberOfBars {
      progressBars[i].backgroundColor = color
      i += 1
    }
  }
  
  // MARK: Alerts

  fileprivate func showUserPicker() {
    let userPickerAlert = UIAlertController(title: "Choose user",
                                            message: "What's your name?",
                                            preferredStyle: .actionSheet)
    for user in users {
      userPickerAlert.addAction(UIAlertAction(title: user,
                                              style: .default,
                                              handler: { [weak self] (action) in
        self?.userId = action.title
        self?.fetchWorkoutsAndUpdateUI()
      }))
    }
    present(userPickerAlert, animated: true, completion: nil)
  }
  
  fileprivate func showWorkoutDetailAlert() {
    let workoutDescriptionAlert = UIAlertController(title: "Check in",
                                                    message: "Enter a description of your workout",
                                                    preferredStyle: .alert)
    workoutDescriptionAlert.addTextField { textField in
      textField.placeholder = "yoga, Muay Thai, dance class"
    }
    
    let checkInAction = UIAlertAction(title: "Check in", style: .default) { [weak workoutDescriptionAlert] action in
      guard let description = workoutDescriptionAlert?.textFields?.first?.text else {
        return
      }
      self.checkInWorkout(with: description)
    }
    
    workoutDescriptionAlert.addAction(checkInAction)
    workoutDescriptionAlert.addAction(UIAlertAction(title: "Cancel",
                                                    style: .cancel,
                                                    handler: nil))
    
    present(workoutDescriptionAlert, animated: true, completion: nil)
  }
  
  fileprivate func checkInWorkout(with description: String) {
    guard let userId = userId else {
      showUserPicker()
      return
    }
    
    let workoutDictionary: [String: Any] = ["date": Date().timeIntervalSince1970, "desc": description, "userId": userId]
    let workout = Workout(dictionary: workoutDictionary)
    guard let w = workout else {
      assertionFailure("Malformed workout")
      return
    }
    
    guard let viewModel = viewModel else {
      assertionFailure("View model is nil")
      return
    }
    viewModel.workouts.append(w)
    updateUI()
    saveWorkoutToDatabase(w)
  }
  
  // MARK: Networking
  
  fileprivate func saveWorkoutToDatabase(_ workout: Workout) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    var ref: DocumentReference? = nil
    ref = database.collection("workouts").addDocument(data: [
      "date": workout.date.timeIntervalSince1970,
      "desc": workout.desc,
      "userId": workout.userId
    ]) { err in
      UIApplication.shared.isNetworkActivityIndicatorVisible = false
      if let err = err {
        print("Error adding document: \(err)")
      } else {
        print("Document added with ID: \(ref!.documentID)")
      }
    }
  }
  
  fileprivate func fetchWorkouts(startDate: Date,
                                 endDate: Date,
                                 completion: @escaping ([Workout]) -> Void) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    _ = database.collection("workouts").whereField("date", isGreaterThan: startDate.timeIntervalSince1970).whereField("date", isLessThan: endDate.timeIntervalSince1970).getDocuments { (querySnapshot, error) in
      UIApplication.shared.isNetworkActivityIndicatorVisible = false
      var workoutObjects = [Workout]()
      guard let workouts = querySnapshot?.documents else {
        // assertionFailure("Workouts failed to load")
        completion(workoutObjects)
        return
      }
      for workout in workouts {
        guard let w = Workout(dictionary: workout.data()) else {
          assertionFailure("Failed to create workout")
          break
        }
        workoutObjects.append(w)
      }
      completion(workoutObjects)
    }
  }
  
  /* Doesn't work
  fileprivate func addListener() {
    database.collection("workouts").whereField("date", isGreaterThan: DateUtils.startOfWeek.timeIntervalSince1970).whereField("date", isLessThan: DateUtils.endOfWeek.timeIntervalSince1970).addSnapshotListener { querySnapshot, error in
      guard let documents = querySnapshot?.documents else {
        print("Error fetching documents: \(error!)")
        return
      }
      guard let newWorkoutDictionary = documents.first?.data() else {
        return
      }
      let workout = Workout(dictionary: newWorkoutDictionary)!
      self.viewModel?.workouts.append(workout)
      self.updateUI()
    }
  }
 */
}

