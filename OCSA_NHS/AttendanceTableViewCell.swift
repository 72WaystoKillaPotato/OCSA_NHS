//
//  AttendanceTableViewCell.swift
//  OCSA_NHS
//
//  Created by Samantha Su on 9/24/20.
//  Copyright © 2020 samsu. All rights reserved.
//

import UIKit

class AttendanceTableViewCell: UITableViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var attendanceDate: UILabel!
    @IBOutlet weak var attendanceState: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        containerView.layer.cornerRadius = 20
        containerView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
