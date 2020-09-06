//
//  EventTableViewCell.swift
//  OCSA_NHS
//
//  Created by Samantha Su on 7/29/20.
//  Copyright © 2020 samsu. All rights reserved.
//

import FoldingCell
import UIKit

class EventTableViewCell: FoldingCell {
    
    //links
    var waiverURL:URL?
    var signupGeniusURL:URL?
    
    //foreground view elements
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var coordinator: UILabel!
    @IBOutlet weak var slots: UILabel!
    @IBOutlet weak var credit: UILabel!
    
    //container view elements
    @IBOutlet weak var nameOrange: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var insideAddress: UILabel!
    @IBOutlet weak var insideCoordinator: UILabel!
    @IBOutlet weak var coordinatorEmail: UILabel!
    @IBOutlet weak var waiverLink: UIButton!
    @IBOutlet weak var signupGeniusLink: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func animationDuration(_ itemIndex:NSInteger, type:AnimationType)-> TimeInterval {

        // durations count equal it itemCount
        let durations = [0.33, 0.26, 0.26] // timing animation for each view
        return durations[itemIndex]
    }
    
    @IBAction func openWaiver(_ sender: Any) {
        if let url = waiverURL{
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func openSignUpGenius(_ sender: Any) {
        if let url = signupGeniusURL{
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
