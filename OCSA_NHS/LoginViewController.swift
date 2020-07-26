//
//  LoginViewController.swift
//  OCSA_NHS
//
//  Created by Samantha Su on 7/18/20.
//  Copyright © 2020 samsu. All rights reserved.
//

import Firebase
import FirebaseAuth
import GoogleSignIn
import UIKit

class LoginViewController: UIViewController{
    @IBOutlet weak var googleSignInButton: UIButton!
    
    @IBAction func signIn(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
    }
}

extension LoginViewController: GIDSignInDelegate{
        func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
            if let error = error {
            print(error.localizedDescription)
            return
            }
            guard let auth = user.authentication else { return }
            let credentials = GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken)
            Auth.auth().signIn(with: credentials) { (authResult, error) in
            if let error = error {
            print(error.localizedDescription)
            } else {
                print("Login Successful. Is new user? ", authResult?.additionalUserInfo?.isNewUser ?? 0)
                //check if the user has profile stored in Realtime Database
                if let userID = Auth.auth().currentUser?.uid{
                    Database.database().reference().child("users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                        if snapshot.exists(){
                            print("user has already saved a profile")
                            let destination = self.storyboard?.instantiateViewController(withIdentifier: "tabBarVC") as! HomeViewController
                            destination.modalPresentationStyle = .fullScreen
                            self.present(destination, animated: true, completion: nil)
                        } else {
                            print("user has not saved a profile")
                            let destination = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileViewController
                            destination.modalPresentationStyle = .fullScreen
                            self.present(destination, animated: true, completion: nil)
                            }
                        }){ (error) in
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}
