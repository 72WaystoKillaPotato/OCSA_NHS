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
    func profile(didFinishFetching: Bool, firstN: String, lastN: String, credits: [String: String], grade: String)
}

class ProfileFetcher: NSObject {
    
    weak var delegate: ProfileUpdatesDelegate?
    fileprivate let downloadGroup = DispatchGroup()
    
    func cacheOrFetch(){
        if let cachedVersion = cache.object(forKey: "profile") as? [String: AnyObject]{
            // use the cached version
            print("cached version used")
            self.unpackProfile(profile: cachedVersion)
        } else{
            fetchProfile()
        }
    }
    
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
        var firstName: String?
        var credits: [String: String] = [:]
        var grade: String?
        
        guard let creditsFiltering: [String: AnyObject] = profile["Credits"] as? [String: AnyObject] else{
            print("unpacking credits and found nil/wrong data types.")
            return
        }
        
//        filter credits so it doesn't contain ""
        var creditsFiltered: [String: Int] = [:]
        for (key, value) in creditsFiltering{
            if let newEntry = value as? Int{
                creditsFiltered[key] = newEntry
            }
        }
        
        guard let gradeInt:String = profile["Grade"] as? String, let lastName = profile["Last Name"] as? String, profile["First Name"] != nil || profile["Preferred Name"] != nil else {
            print("unpacking profile and found nil/wrong data types.")
            return
        }
        
        //birthday
//        let unixDate = profile["Birthday"] as? Double
//        let birthDate = NSDate(timeIntervalSince1970: unixDate) as Date
//        let ageComponents = Calendar.current.dateComponents([.year], from: birthDate, to: Date())
//        age = ageComponents.year!
        
        //preferred name or first name
        if let name = profile["Preferred Name"] as? String{
            firstName = name
        } else {
            firstName = profile["First Name"] as? String
        }

        //credits
        let creditCodes = creditsFiltered.compactMapValues {$0}
//        print("creditCodes = \(creditCodes)")
        for (key, eventKey) in creditCodes{
            downloadGroup.enter()
            let keyString = String(eventKey)
            Database.database().reference().child("events").child(keyString).child("name").observeSingleEvent(of: .value) { (snapshot) in
                guard snapshot.exists() else {
                    return
                }
                credits[key] = snapshot.value as? String
                self.downloadGroup.leave()
            }
        }
        self.downloadGroup.notify(queue: .main) {
            self.delegate?.profile(didFinishFetching: true, firstN: firstName!, lastN: lastName, credits: credits, grade: grade!)
        }
        
        //grade
        switch gradeInt {
            case "9":
                grade = "Freshman"
            case "10":
                grade = "Sophomore"
            case "11":
                grade = "Junior"
            case "12":
                grade = "Senior"
            default:
                grade = "Grade Not Found"
        }
    }
}
