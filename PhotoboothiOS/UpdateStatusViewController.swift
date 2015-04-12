//
//  StatusUpdateViewController.swift
//  Swifter
//
//  Created by Ryan Choi on 4/8/15.
//  Copyright (c) 2015 Matt Donnelly. All rights reserved.
//

import UIKit
import SwifteriOS

class UpdateStatusViewController: UIViewController {
    
    var beenHereBefore = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if beenHereBefore{
            /* Only display the picker once as the viewDidAppear: method gets
            called whenever the view of our view controller gets displayed */
            return;
        } else {
            beenHereBefore = true
        }
    }
    
}