//
//  Event.swift
//  OCSA_NHS
//
//  Created by Samantha Su on 7/29/20.
//  Copyright © 2020 samsu. All rights reserved.
//

import UIKit

class Event: NSObject{
    var name: String?
    var date: String?
    var time: String?
    var address: String?
    var coordinator: String?
    var coordinatorEmail: String?
    var eventDescription: String?
    
    var slots: Int?
    var credit: Int?
    
    var waiverLink: URL?
    var signupGeniusLink: URL?
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        self.name = dictionary["name"] as? String
        self.date = dictionary["date"] as? String
        self.time = dictionary["time"] as? String
        self.address = dictionary["address"] as? String
        self.coordinator = dictionary["coordinator"] as? String
        self.coordinatorEmail = dictionary["coordinatorEmail"] as? String
        self.slots = dictionary["slots"] as? Int
        self.credit = dictionary["credit"] as? Int
        
        self.waiverLink = dictionary["waiverLink"] as? URL
        self.signupGeniusLink = dictionary["signupGeniusLink"] as? URL
    }
}
