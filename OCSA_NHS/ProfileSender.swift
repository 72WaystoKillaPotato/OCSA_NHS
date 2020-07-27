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
    var profile: [String: Any?]
    
    let photoUploadGroup = DispatchGroup()
    
    init(profile: [String: Any?]){
        self.profile = profile
        self.profile.removeValue(forKey: "checkRowTag")
        if self.profile["Preferred Name"] == nil{
            self.profile.removeValue(forKey: "Preferred Name")
        }
        print("profile = ", self.profile)
        
        super.init()
    }
    
    func sendProfile(){
        print("sending profile")
        photoUploadGroup.enter()
        uploadProfilePic(profile["Profile Picture"] as! UIImage)
        photoUploadGroup.notify(queue: .main) {
            self.uploadProfileText()
        }
    }
    
    fileprivate func uploadProfilePic(_ image: UIImage){
        let imageName = UUID().uuidString
        let ref = Storage.storage().reference().child("profilePictures").child(imageName)

        guard let uploadData =  image.jpegData(compressionQuality: 1) else { return }
        ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
          guard error == nil else { return }
          
          ref.downloadURL(completion: { (url, error) in
            guard error == nil, let imageURL = url else { return }
            self.profile["Profile Picture"] = imageURL.absoluteString
            print("photo successfully uploaded")
            self.photoUploadGroup.leave()
          })
        })
    }
    
    fileprivate func uploadProfileText(){
        let date = self.profile["Birthday"] as! Date
        self.profile["Birthday"] = NSNumber(value: Int(date.timeIntervalSince1970))
//        if let unixDate = snapshot.value as? Double{
//        let staticLoginDate = NSDate(timeIntervalSince1970: unixDate) as Date
        if let uid = Auth.auth().currentUser?.uid{
            Database.database().reference().child("users").child(uid).setValue(self.profile)
            print("finished sending profile")
        }
    }
}
