//
//  HomeViewController.swift
//  OCSA_NHS
//
//  Created by Samantha Su on 7/20/20.
//  Copyright © 2020 samsu. All rights reserved.
//

import UIKit

let cache = NSCache<NSString, NSDictionary>()
class HomeViewController: UITabBarController{
    
    override func viewDidLoad() {
        selectedIndex = 1
    }
}
