//
//  EventDetailViewController.swift
//  Calendar
//
//  Created by Admin on 11/06/24.
//

import UIKit
import CoreData

// MARK: - Protocol

protocol EventCreationDelegate: AnyObject {
    func didFinishCreatingEvent(eventName: String, eventDescription: String, eventTitle: String, forDate: Date)
}

class EventDetailViewController: UIViewController{
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var timeTextField: UITextField!
    
    @IBOutlet weak var dateTimeLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    
    // MARK: - Declarations
    
    var selectedDate: Date?
    var formattedDateString: String?
    weak var delegate: EventCreationDelegate?
    var eventDataDict: [String: (eventName: String, eventDescription: String, eventTitle: String, forDate: Date)] = [:]
    var eventData: UserEntity?
    
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let formattedDateString = formattedDateString,
           let eventData = eventDataDict[formattedDateString] {
            // Display the data in the labels
            titleTextField.text = eventData.eventTitle
            timeTextField.text = eventData.eventName
        }
        timeTextField.attributedPlaceholder = NSAttributedString(string: "HH:MM", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        let timeTapGesture = UITapGestureRecognizer(target: self, action: #selector(showTimeActionSheet))
        timeTextField.addGestureRecognizer(timeTapGesture)
        
        if let selectedDate = selectedDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d-MMM-yyyy"
            dateTimeLabel.text = dateFormatter.string(from: selectedDate)
        }
    }
    
    @objc func showTimeActionSheet() {
        let alertController = UIAlertController(title: "Select Time", message: nil, preferredStyle: .actionSheet)
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        datePicker.preferredDatePickerStyle = .wheels
        
        alertController.view.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 20).isActive = true
        datePicker.bottomAnchor.constraint(equalTo: alertController.view.bottomAnchor, constant: -100).isActive = true
        datePicker.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 40).isActive = true
        datePicker.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -20).isActive = true
        
        let selectAction = UIAlertAction(title: "Select", style: .default) { _ in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            self.timeTextField.text = dateFormatter.string(from: datePicker.date)
        }
        alertController.addAction(selectAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Button Actions
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let eventName = timeTextField.text,
              let eventDescription = descriptionTextView.text,
              let eventTitle = titleTextField.text,
              let selectedDate = selectedDate,
              let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "UserEntity", in: managedContext)!
        let event = NSManagedObject(entity: entity, insertInto: managedContext)
        
        event.setValue(eventName, forKey: "time")
        event.setValue(eventDescription, forKey: "descriptiontext")
        event.setValue(eventTitle, forKey: "title")
        event.setValue(selectedDate, forKey: "date")
        
        let calendar = Calendar.current
        let year = calendar.component(.year, from: selectedDate)
        let month = calendar.component(.month, from: selectedDate)
        
        event.setValue(year, forKey: "year")
        event.setValue(month, forKey: "month")
        
        do {
            try managedContext.save()
            print("Event saved successfully")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        delegate?.didFinishCreatingEvent(eventName: eventName, eventDescription: eventDescription, eventTitle: eventTitle, forDate: selectedDate)
        
        navigationController?.popViewController(animated: true)
    }
}
