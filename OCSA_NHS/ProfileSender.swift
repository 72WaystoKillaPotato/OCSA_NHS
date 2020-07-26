//
//  ProfileSender.swift
//  OCSA_NHS
//
//  Created by Samantha Su on 7/20/20.
//  Copyright © 2020 samsu. All rights reserved.
//

import UIKit
import Firebase

protocol ProfileSenderDelegate {
    
}

class ProfileSender: NSObject{
    var profile: [String: Any?]!
    
    init(profile: [String: Any?]){
        super.init()
        self.profile = profile
    }
    
    func sendProfile(){
        print("sending profile")
    }
}
