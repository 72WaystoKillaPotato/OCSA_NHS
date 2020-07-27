//
//  ProfileViewController.swift
//  OCSA_NHS
//
//  Created by Samantha Su on 7/18/20.
//  Copyright © 2020 samsu. All rights reserved.
//

import UIKit
import FirebaseAuth
import Eureka
import ImageRow
import Photos

class ProfileViewController: FormViewController{
//    @IBAction func signOut(_ sender: Any) {
//        let firebaseAuth = Auth.auth()
//        do {
//          try firebaseAuth.signOut()
//            print("signed out")
//        } catch let signOutError as NSError {
//          print ("Error signing out: %@", signOutError)
//        }
//
//    }
    let group = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        group.enter()
        checkAuthorizationStatus()
        group.notify(queue: .main){
            self.form
        +++ Section("About Me")
            <<< ImageRow("Profile Picture") {
                $0.title = "Profile Picture"
                $0.sourceTypes = .PhotoLibrary
                $0.clearAction = .yes(style: UIAlertAction.Style.destructive)
                $0.add(rule: RuleRequired())
            }.cellUpdate { cell, row in
                cell.accessoryView?.layer.cornerRadius = 17
                cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
                if !row.isValid {
                    cell.textLabel?.textColor = .systemRed
                }
            }.onCellSelection{ cell, row in
                
            }
            <<< NameRow("First Name"){ row in
                row.title = "First Name"
                row.add(rule: RuleRequired())
            }.cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            }
            <<< NameRow("Last Name"){ row in
                row.title = "Last Name"
                row.add(rule: RuleRequired())
            }.cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            }
            <<< CheckRow("checkRowTag"){
                $0.title = "I have a preferred name"
            }
            <<< NameRow("Preferred Name"){

                $0.hidden = Condition.function(["checkRowTag"], { form in
                    return !((form.rowBy(tag: "checkRowTag") as? CheckRow)?.value ?? false)
                })
                $0.title = "Preferred Name"
            }
            <<< PhoneRow("Phone Number"){
                $0.title = "Phone Number"
                $0.add(rule: RuleRequired())
                $0.add(rule: RuleMinLength(minLength: 11))
                $0.add(rule: RuleMaxLength(maxLength: 11))
                $0.placeholder = "10001234567"
            }.cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            }
            <<< DateRow("Birthday"){
                $0.title = "Birthday"
                $0.add(rule: RuleRequired())
            }.cellUpdate { cell, row in
                if !row.isValid {
                    cell.textLabel?.textColor = .systemRed
                }
            }
        +++ Section("School Info")
            <<< SegmentedRow<String>("Grade") {
                $0.options = ["9", "10", "11", "12"]
                $0.title = "Grade"
                $0.add(rule: RuleRequired())
            }.cellUpdate { cell, row in
                if !row.isValid {
                    cell.textLabel?.textColor = .systemRed
                }
            }
            <<< PhoneRow("ID"){
                $0.title = "Student ID (last four digits)"
                $0.add(rule: RuleRequired())
                $0.add(rule: RuleMinLength(minLength: 4))
                $0.add(rule: RuleMaxLength(maxLength: 4))
            }.cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            }
            <<< PushRow<String>("Conservatory"){
                $0.title = "Conservatory"
                $0.options = ["Culinary Arts", "Ballet Folklórico", "Ballroom Dance", "Classical & Contemporary Dance", "Commercial Dance", "Creative Writing", "Digital Media", "Film & Television", "Integrated Arts", "Visual Arts", "Classical Voice", "Instrumental Music", "Popular Music", "Acting", "Musical Theatre", "Production & Design"]
                $0.selectorTitle = "Choose your conservatory"
                $0.add(rule: RuleRequired())
                }.onPresent { from, to in
                    to.modalPresentationStyle = .fullScreen
                    to.dismissOnSelection = true
                    to.dismissOnChange = true
                    to.sectionKeyForValue = { option in
                        switch option {
                        case "Culinary Arts": return "School of Applied Arts"
                        case "Ballet Folklórico", "Ballroom Dance", "Classical & Contemporary Dance", "Commercial Dance": return "School of Dance"
                        case "Creative Writing", "Digital Media", "Film & Television", "Integrated Arts", "Visual Arts": return "School of Fine & Media Arts"
                        case "Classical Voice", "Instrumental Music", "Popular Music": return "School of Music"
                        case "Acting", "Musical Theatre", "Production & Design": return "School of Theatre"
                        default: return ""
                        }
                    }
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.textLabel?.textColor = .systemRed
                    }
                }
        +++ Section(footer: "Note: your profile is final. If changes are necessary, email ziyao.su@ocsarts.net with the title 'APP: Profile Change'")
            <<< ButtonRow() {
                $0.title = "Submit Profile"
            }
            .onCellSelection { cell, row in
                print(self.form.values())
                if self.form.validate().isEmpty{
                    let profileSender = ProfileSender(profile: self.form.values())
                    profileSender.sendProfile()
                    let destination = self.storyboard?.instantiateViewController(withIdentifier: "tabBarVC") as! HomeViewController
                    self.navigationController?.pushViewController(destination, animated: true)
                }
            }
        }
    }
    
    fileprivate func checkAuthorizationStatus() {
      let status = PHPhotoLibrary.authorizationStatus()
      switch status {
      case .authorized:
        group.leave()
        break
      case .denied, .restricted:
        break
      case .notDetermined:
        PHPhotoLibrary.requestAuthorization { status in
          switch status {
          case .authorized:
            self.group.leave()
            break
          case .denied, .restricted, .notDetermined:
            break
                  @unknown default:
                      fatalError()
                  }
        }
          @unknown default:
              fatalError()
          }
    }
    
}
