//
//  EventFetcher.swift
//  OCSA_NHS
//
//  Created by Samantha Su on 8/14/20.
//  Copyright © 2020 samsu. All rights reserved.
//

import UIKit
import Firebase

protocol EventUpdatesDelegate: class {
    func events(didFinishFetching: Bool, events: [Event])
}

class EventFetcher: NSObject {
    
    weak var delegate: EventUpdatesDelegate?
    fileprivate let downloadGroup = DispatchGroup()
    var eventsArray: [Event] = []
    
    func fetchUserInfo(){
        guard let ownerID = Auth.auth().currentUser?.uid else { return }
        eventsArray = []
        var credits: [Int] = []
        //get student ID from key
        Database.database().reference().child("keys").child(ownerID).observeSingleEvent(of: .value) { (snapshot) in
            guard snapshot.exists() else {return}
            guard let studentID = snapshot.value as? String else {return}
            //get profile from student ID
            Database.database().reference().child("users").child(studentID).observeSingleEvent(of: .value) { (snapshot) in
                guard snapshot.exists() else {
                    return
                }
//                print("snapshot = ", snapshot)
                if let creditsDict = snapshot.childSnapshot(forPath: "Credits").value as? [String: Int]{
                    credits = Array(creditsDict.values)
                }
                if let eventsDict = snapshot.childSnapshot(forPath: "Events").value as? [String: Int]{
                    var events = Array(eventsDict.values)
                    for (index, event) in events.enumerated(){
                        credits.forEach{credit in
                            if event == credit{
                                events.remove(at: index)
                            }
                        }
                    }
                    self.fetchEvents(eventCodes: events)
                }
            }
        }
    }
    
    fileprivate func fetchEvents(eventCodes: [Int]){
        for value in eventCodes{
            let valueString = String(value)
            self.downloadGroup.enter()
            Database.database().reference().child("events").child(valueString).observeSingleEvent(of: .value) { (snapshot) in
                guard snapshot.exists() else {
                    return
                }
                if let event = snapshot.value as? [String: AnyObject]{
//                    print(event)
                    self.eventsArray.append(Event(dictionary: event))
                    self.downloadGroup.leave()
                }
            }
        }
        self.downloadGroup.notify(queue: .main) {
            self.delegate?.events(didFinishFetching: true, events: self.eventsArray)
        }
    }
}
