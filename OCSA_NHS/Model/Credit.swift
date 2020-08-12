//
//  Credit.swift
//  OCSA_NHS
//
//  Created by Samantha Su on 8/11/20.
//  Copyright © 2020 samsu. All rights reserved.
//

import UIKit

class Credit: NSObject {
    var name: String?
    var instances: Int?
    
    init(name: String, instances: Int) {
        self.name = name
        self.instances = instances
    }
}
