//
//  MemberProfileViewController.swift
//  OCSA_NHS
//
//  Created by Samantha Su on 7/29/20.
//  Copyright © 2020 samsu. All rights reserved.
//

import UIKit
import Firebase
import PieCharts

class MemberProfileViewController: UIViewController{
    
    var credits : [Credit] = []
    var creditsIsComplete: Bool = true
    
    let profileFetcher = ProfileFetcher()
    
    @IBOutlet weak var creditPieChart: PieChart!
    fileprivate static let alpha: CGFloat = 1
    let colors = [
        UIColor(displayP3Red: 62.0/255.0, green: 70.0/255.0, blue: 112.0/255.0, alpha: 0.9),
        UIColor(displayP3Red: 255.0/255.0, green: 251.0/255.0, blue: 151.0/255.0, alpha: alpha),
        UIColor(displayP3Red: 255.0/255.0, green: 230.0/255.0, blue: 137.0/255.0, alpha: alpha),
        UIColor(displayP3Red: 254.0/255.0, green: 196.0/255.0, blue: 112.0/255.0, alpha: alpha),
        UIColor(displayP3Red: 255.0/255.0, green: 147.0/255.0, blue: 72.0/255.0, alpha: alpha),
        UIColor(displayP3Red: 254.0/255.0, green: 112.0/255.0, blue: 32.0/255.0, alpha: alpha)
    ]
    fileprivate var currentColorIndex = 0
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var noCreditsLabel: UILabel!
    
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
    
    override func viewDidLoad() {
        profileFetcher.delegate = self
        profileFetcher.cacheOrFetch()
        
        creditPieChart.delegate = self
//        nameLabel.alpha = 0
//        gradeLabel.alpha = 0
//        noCreditsLabel.alpha = 0
    }
    
    // MARK: - Model
    
    fileprivate func createModels() -> [PieSliceModel] {
        var models: [PieSliceModel] = []
        
        guard !self.credits.isEmpty else {
            noCreditsLabel.alpha = 0.7
            return []
        }
        
        for i in 0...credits.count - 1{
            models.append(PieSliceModel(value: Double(credits[i].instances ?? 0), color: colors[i + 1], obj: credits[i].name))
        }
        
        //complete self.credits to be 6
        let totalEventCredits = self.credits.compactMap({$0.instances})
        let totalCredits = totalEventCredits.reduce(0, +)
        print("totalCredits = ", totalCredits)
        if totalCredits < 6{
            creditsIsComplete = false
            models.append(PieSliceModel(value: Double(6 - totalCredits), color: colors[0]))
        }
        
        currentColorIndex = models.count
        return models
    }
    
    // MARK: - Text Layer
    
    fileprivate func createTextLayer() -> PiePlainTextLayer {
        let textLayerSettings = PiePlainTextLayerSettings()
        textLayerSettings.viewRadius = 90
        textLayerSettings.hideOnOverflow = true
        textLayerSettings.label.font = UIFont(name: "Futura", size: 15)!
        textLayerSettings.label.textColor = UIColor(displayP3Red: 62.0/255.0, green: 70.0/255.0, blue: 112.0/255.0, alpha: 1.0)
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        textLayerSettings.label.textGenerator = {slice in
            if let eventName = slice.data.model.obj as? String{
                return eventName
            } else {
                return ""
            }
        }
        
        let textLayer = PiePlainTextLayer()
        textLayer.settings = textLayerSettings
        return textLayer
    }
    
}

extension MemberProfileViewController: ProfileUpdatesDelegate{
    func noCreditProfile(didFinishFetching: Bool, firstN: String, lastN: String, grade: String) {
        print("hey wtf")
        nameLabel.text = firstN + " " + lastN
        gradeLabel.text = grade
    }
    
    func profile(didFinishFetching: Bool, firstN: String, lastN: String, credits: [String : String], grade: String) {
        var creditsMutable = credits
        
        var isDuplicate: Bool = false
        
        //calculate proportions of the pie chart
        //for every credit,
        for (credit, event) in creditsMutable{
            //iterate through stored credits
            for chartCredit in self.credits{
                //if event has already been stored, add one instance
                if chartCredit.name == event{
                    chartCredit.instances! += 1
                    isDuplicate = true
                }
            }
            if isDuplicate == true{
                creditsMutable.removeValue(forKey: credit)
            }else {
                if self.credits.count < 6{
                    self.credits.append(Credit(name: event, instances: 1))
                }
            }
            isDuplicate = false
        }
        
//        print(self.credits.map({$0.instances}))
//        print(self.credits.map({$0.name}))
        
        creditPieChart.layers = [createTextLayer()]
        
        creditPieChart.models = createModels()
        
        //take care of labels
        nameLabel.text = firstN + " " + lastN
        gradeLabel.text = grade
        noCreditsLabel.alpha = 0
    }
}

extension MemberProfileViewController: PieChartDelegate{
    func onSelected(slice: PieSlice, selected: Bool) {
//        print("selected")
    }
}
