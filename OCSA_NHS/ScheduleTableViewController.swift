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
    
    var cellHeights = Array(repeating: CellHeight.close, count: CellHeight.cellCount)
    let eventFetcher = EventFetcher()
    
    var events: [Event] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @objc func refreshHandler() {
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
        return CellHeight.cellCount
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoldingCell", for: indexPath) as! FoldingCell
        let durations: [TimeInterval] = [0.26, 0.2]
        cell.durationsForExpandedState = durations
        cell.durationsForCollapsedState = durations
        
        //customize cells if [Events] is not empty
        if !events.isEmpty{
            
        }
        
        return cell
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
        self.events = events
        tableView.reloadData()
    }
}
