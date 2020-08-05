//
//  ProfileFetcher.swift
//  OCSA_NHS
//
//  Created by Samantha Su on 8/4/20.
//  Copyright © 2020 samsu. All rights reserved.
//

import UIKit
import Firebase

protocol ProfileUpdatesDelegate: class {
//    func profile(didFinishFetching: Bool, profile: [String: AnyObject])
}

class ProfileFetcher: NSObject {
    func fetchProfile(){
        guard let ownerID = Auth.auth().currentUser?.uid else { return }
        //get student ID from key
        Database.database().reference().child("keys").child(ownerID).observeSingleEvent(of: .value) { (snapshot) in
            guard snapshot.exists() else {return}
            guard let studentID = snapshot.value as? String else {return}
            //get profile from student ID
            Database.database().reference().child("users").child(studentID).observeSingleEvent(of: .value) { (snapshot) in
                guard snapshot.exists() else {
                    return
                }
                if let studentProfile = snapshot.value as? [String: AnyObject]{
                    self.unpackProfile(profile: studentProfile)
                }
            }
        }
    }
    
    fileprivate func unpackProfile(profile: [String: AnyObject]){
        var age: Int?
        var firstName: String?
        //birthday
        if let unixDate = profile["Birthday"] as? Double{
            let birthDate = NSDate(timeIntervalSince1970: unixDate) as Date
            let ageComponents = Calendar.current.dateComponents([.year], from: birthDate, to: Date())
            age = ageComponents.year!
        }
        //preferred name or first name
        if let name = profile["Preferred Name"] as? String{
            firstName = name
        } else {
            firstName = profile["First Name"] as? String
        }
        
        //credits
//        let credits: []
    }
}
