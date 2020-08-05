//
//  MemberProfileViewController.swift
//  OCSA_NHS
//
//  Created by Samantha Su on 7/29/20.
//  Copyright © 2020 samsu. All rights reserved.
//

import UIKit
import Firebase

class MemberProfileViewController: UIViewController{
    
    @IBAction func signOut(_ sender: Any) {
        let firebaseAuth = Auth.auth()
            do {
              try firebaseAuth.signOut()
                self.dismiss(animated: true, completion: nil)
                print("signed out")
            } catch let signOutError as NSError {
              print ("Error signing out: %@", signOutError)
            }
    }
}
