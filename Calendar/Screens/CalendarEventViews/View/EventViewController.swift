//
//  EventViewController.swift
//  Calendar
//
//  Created by Admin on 11/06/24.
//
import Foundation
import UIKit
import CoreData

class EventViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var yearTextField: UITextField!
    
    @IBOutlet weak var monthTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Declarations
    
    var selectedMonth: Int?
    var selectedYear: Int?
    var eventDataDict: [String: (eventName: String, eventDescription: String, eventTitle: String, forDate: Date)] = [:]
    var selectedDate: Date?
    weak var delegate: EventCreationDelegate?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        
        let monthPlaceholderColor = UIColor.white
        let yearPlaceholderColor = UIColor.white
        
        monthTextField.attributedPlaceholder = NSAttributedString(string: "Month", attributes: [NSAttributedString.Key.foregroundColor: monthPlaceholderColor])
        yearTextField.attributedPlaceholder = NSAttributedString(string: "Year", attributes: [NSAttributedString.Key.foregroundColor: yearPlaceholderColor])
        
        let monthTapGesture = UITapGestureRecognizer(target: self, action: #selector(showMonthActionSheet))
        monthTextField.addGestureRecognizer(monthTapGesture)
        
        let yearTapGesture = UITapGestureRecognizer(target: self, action: #selector(showYearActionSheet))
        yearTextField.addGestureRecognizer(yearTapGesture)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "EventCell", bundle: nil), forCellReuseIdentifier: "EventCell")
    }
    
    @objc func showMonthActionSheet() {
        let alertController = UIAlertController(title: "Month", message: nil, preferredStyle: .actionSheet)
        
        let dateFormatter = DateFormatter()
        for month in 1...12 {
            let date = Calendar.current.date(from: DateComponents(year: 2000, month: month, day: 1))!
            dateFormatter.dateFormat = "MMM"
            let monthName = dateFormatter.string(from: date)
            
            let monthAction = UIAlertAction(title: monthName, style: .default) { _ in
                self.monthTextField.text = monthName
                self.selectedMonth = month
                self.updateTableView()
            }
            alertController.addAction(monthAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func showYearActionSheet() {
        let alertController = UIAlertController(title: "Year", message: nil, preferredStyle: .actionSheet)
        
        let currentYear = Calendar.current.component(.year, from: Date())
        for year in (2016...2025).reversed() {
            let yearAction = UIAlertAction(title: "\(year)", style: .default) { _ in
                self.yearTextField.text = "\(year)"
                self.selectedYear = year
                self.updateTableView()
            }
            alertController.addAction(yearAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func updateTableView() {
        tableView.reloadData()
    }
    
    func normalize(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d-MMM-yyyy"
        return formatter.string(from: date)
    }
    
    func fetchData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserEntity")
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            eventDataDict.removeAll()  // Clear existing data
            
            for data in result as! [NSManagedObject] {
                guard let eventDate = data.value(forKey: "date") as? Date else {
                    continue
                }
                let eventName = data.value(forKey: "time") as? String ?? ""
                let eventDescription = data.value(forKey: "descriptiontext") as? String ?? ""
                let eventTitle = data.value(forKey: "title") as? String ?? ""
                
                let normalizedDate = normalize(date: eventDate)
                eventDataDict[normalizedDate] = (eventName: eventName, eventDescription: eventDescription, eventTitle: eventTitle, forDate: eventDate)
            }
            
            updateTableView()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}

// MARK: - UITableView Delegate & DataSource


extension EventViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let selectedYear = selectedYear, let selectedMonth = selectedMonth else {
            return 0
        }
        
        let components = DateComponents(year: selectedYear, month: selectedMonth)
        if let date = Calendar.current.date(from: components),
           let range = Calendar.current.range(of: .day, in: .month, for: date) {
            return range.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
        cell.selectionStyle = .none
        cell.dateTimeLabel.isHidden = true
        
        guard let selectedYear = selectedYear, let selectedMonth = selectedMonth else {
            return cell
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        let date = Calendar.current.date(from: DateComponents(year: selectedYear, month: selectedMonth, day: indexPath.row + 1))!
        cell.dateLabel.text = "\(indexPath.row + 1)"
        cell.monthLabel.text = dateFormatter.string(from: date)
        
        let normalizedDate = normalize(date: date)
        if let eventData = eventDataDict[normalizedDate] {
            cell.titleLabel.text = eventData.eventTitle
            
            let displayDateFormatter = DateFormatter()
            displayDateFormatter.dateFormat = "d-MMM-yyyy"
            

            cell.timeLabel.text = "\(eventData.eventName) \(displayDateFormatter.string(from: eventData.forDate))"
            cell.dateTimeLabel.isHidden = true
        } else {
            cell.titleLabel.text = ""
            cell.timeLabel.text = ""
        }
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let selectedYear = selectedYear, let selectedMonth = selectedMonth else {
            return
        }
        
        guard let date = Calendar.current.date(from: DateComponents(year: selectedYear, month: selectedMonth, day: indexPath.row + 1)) else {
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailViewController = storyboard.instantiateViewController(withIdentifier: "EventDetailViewController") as? EventDetailViewController {
            detailViewController.selectedDate = date
            detailViewController.formattedDateString = normalize(date: date)
            detailViewController.delegate = self
            detailViewController.eventDataDict = eventDataDict // Pass eventDataDict
            navigationController?.pushViewController(detailViewController, animated: true)
        }
        
    }}

func normalize(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "d-MMM-yyyy"
    return formatter.string(from: date)
}


extension EventViewController: EventCreationDelegate {
    func didFinishCreatingEvent(eventName: String, eventDescription: String, eventTitle: String, forDate date: Date) {
        let normalizedDate = normalize(date: date)
        eventDataDict[normalizedDate] = (eventName, eventDescription, eventTitle, date)
        tableView.reloadData()
    }
}

