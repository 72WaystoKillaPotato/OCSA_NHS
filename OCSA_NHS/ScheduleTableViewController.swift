//
//  ScheduleTableViewController.swift
//  OCSA_NHS
//
//  Created by Samantha Su on 7/29/20.
//  Copyright © 2020 samsu. All rights reserved.
//

import FoldingCell
import UIKit

class ScheduleTableViewController: UITableViewController {
    struct CellHeight {
        static let close: CGFloat = 185 // equal or greater foregroundView height
        static let open: CGFloat = 461 // equal or greater containerView height
        static let cellCount: Int = 5
    }
    
    var cellHeights: [CGFloat] = []
    let eventFetcher = EventFetcher()
    
    var events: [Event] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cellHeights = Array(repeating: CellHeight.close, count: events.count)
        
        eventFetcher.delegate = self
        eventFetcher.fetchUserInfo()
        
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = CellHeight.close
        tableView.rowHeight = CellHeight.close
        if #available(iOS 10.0, *) {
            tableView.refreshControl = UIRefreshControl()
            tableView.refreshControl?.addTarget(self, action: #selector(refreshHandler), for: .valueChanged)
        }
        
        let tempImageView = UIImageView(image: UIImage(named: "background"))
        tempImageView.frame = self.tableView.frame
        self.tableView.backgroundView = tempImageView
        
        //refresh control
        if #available(iOS 10.0, *) {//33, 40, 86
            tableView.refreshControl = UIRefreshControl()
            tableView.refreshControl?.tintColor = UIColor(displayP3Red: 33.0/255.0, green: 40.0/255.0, blue: 86.0/255.0, alpha: 1)
            tableView.refreshControl?.addTarget(self, action: #selector(refreshHandler), for: .valueChanged)
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @objc func refreshHandler() {
        eventFetcher.fetchUserInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - Folding Cell config
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard case let cell as EventTableViewCell = tableView.cellForRow(at: indexPath) else {
          return
        }

        var duration = 0.0
        let cellIsCollapsed = cellHeights[indexPath.row] == CellHeight.close
        if cellIsCollapsed {
            cellHeights[indexPath.row] = CellHeight.open
            cell.unfold(true, animated: true, completion: nil)
            duration = 0.5
        } else {
            cellHeights[indexPath.row] = CellHeight.close
            cell.unfold(false, animated: true, completion: nil)
            duration = 0.8
        }

        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
            tableView.beginUpdates()
            tableView.endUpdates()
        }, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if case let cell as EventTableViewCell = cell {
            cell.backgroundColor = .clear
            if cellHeights[indexPath.row] == CellHeight.close {
                cell.unfold(false, animated: false, completion: nil)
            } else {
                cell.unfold(true, animated: false, completion: nil)
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if !events.isEmpty{
            return events.count
        } else {
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoldingCell", for: indexPath) as! EventTableViewCell
        let durations: [TimeInterval] = [0.26, 0.2]
        cell.durationsForExpandedState = durations
        cell.durationsForCollapsedState = durations
        
        //customize cells if [Events] is not empty
        if !events.isEmpty{
            let event = events[indexPath.row]
            cell.date.text = unpackDate(date: event.date ?? "")
            cell.time.text = event.time
            cell.name.text = event.name
            cell.address.text = event.address
            cell.coordinator.text = event.coordinator
            cell.slots.text = "\(event.slots ?? 0)"
            cell.credit.text = "\(event.credit ?? 0)"
            
            cell.nameOrange.text = event.name
            cell.eventDescription.text = event.eventDescription
            cell.insideAddress.text = event.address
            cell.insideCoordinator.text = "Coordinator: \(event.coordinator ?? "")"
            cell.coordinatorEmail.text = "Email: \(event.coordinatorEmail ?? "")"
            cell.waiverURL = event.waiverLink
            cell.signupGeniusURL = event.signupGeniusLink
            
            //disable the cell if the date for the event has passed
            if let date = event.rankingDate{
                if date < Date(){
                    print("event ", event.name ?? "defaultName", "is disabled. ")
                    cell.isUserInteractionEnabled = false
                    cell.name.text = "Event Expired"
                } else{
                    cell.isUserInteractionEnabled = true
                }
            }
        }
        
        return cell
    }
    
    fileprivate func unpackDate(date: String) -> String{
        //date looks something like this: "2020-07-23T07:00:00.000Z"
        if let endIndex = date.firstIndex(of: "T"), let startIndex = date.firstIndex(of: "-"){ //10, 4
            let start = date.index(startIndex, offsetBy: 1)
            let range = start ..< endIndex
            let newDate = String(date[range]).replacingOccurrences(of: "-", with: "/")
            return newDate
        }
        return ""
    }
    
    fileprivate func rankEventsByDate(){
        for event in self.events{
            if let date = event.date, let time = event.time
                , let dateIndex = date.firstIndex(of: "T"), let timeIndex = time.firstIndex(of: "-"){
                let dateSubstring = date[...dateIndex]
                let timeSubstring = time[..<timeIndex]
                let combinedString = dateSubstring + timeSubstring
                let cleanString = combinedString.replacingOccurrences(of: " ", with: "")
                
                //pack date (2020-07-23T18:30) into Date
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
                let finalDate = dateFormatter.date(from:cleanString)!
                event.rankingDate = finalDate
                print("rankingDate = ", finalDate)
            } else{
                event.rankingDate = Date()
            }
        }
        
        self.events = self.events.sorted(by:{ $0.rankingDate!.compare($1.rankingDate!) == .orderedAscending
        })
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}

extension ScheduleTableViewController: EventUpdatesDelegate{
    func events(didFinishFetching: Bool, events: [Event]) {
        if self.tableView.refreshControl?.isRefreshing ?? false {
            self.tableView.refreshControl?.endRefreshing()
        }
        self.events = events
        cellHeights = Array(repeating: CellHeight.close, count: events.count)
        rankEventsByDate()
        tableView.reloadData()
    }
}
