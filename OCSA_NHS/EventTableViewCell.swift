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

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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

}
