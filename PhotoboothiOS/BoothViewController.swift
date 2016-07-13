//
//  BoothViewController.swift
//  Photobooth
//
//  Created by Ryan Choi on 4/29/15.
//  Copyright (c) 2015 Matt Donnelly. All rights reserved.
//

import Foundation

import Foundation
import UIKit
import MobileCoreServices
import TwitterKit

class BoothViewController : UIViewController {
    
    @IBOutlet weak var navbar: UINavigationItem!
    
    func setupNav(enableBackButton : Bool, enableSettings : Bool){
        
        if let navigationController = self.navigationController {
            
            // Get the navigationBar.frame sizes
            let navHeight = navigationController.navigationBar.frame.height
            let navWidth = navigationController.navigationBar.frame.width
            
            // Create a border
            let navBorder = UIView(frame: CGRectMake(0, navHeight - 2, navWidth, 2))
            navBorder.tag = 140
            
            // Change the border to blue
            navBorder.backgroundColor = UIColor(rgba: "#5EA9DD")
            navigationController.navigationBar.addSubview(navBorder)
            
        }
        
        // Append image to the navigation bar
        if let image = UIImage(named: "TwitterLogo") {
        
            let logoView = UIImageView(frame: CGRectMake(0, 0, 30, 30))
        
            logoView.image = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            logoView.contentMode = UIViewContentMode.ScaleAspectFit
            logoView.frame.origin.x = 10
            logoView.frame.origin.y = 8
            
            navbar.titleView = logoView
            
        }
        
        if (!enableBackButton){
            self.navigationItem.setHidesBackButton(true, animated: true)
        }

        if (enableSettings){
            // Add a tap gesture to the navigation bar image to send the user to settings
            let recognizer = UITapGestureRecognizer(target: self, action: "showSettings")
            self.navbar.titleView!.userInteractionEnabled = true
            self.navbar.titleView!.addGestureRecognizer(recognizer)
        }

    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        if let navigationController = self.navigationController,
                border = navigationController.navigationBar.viewWithTag(140) {
        
                    let bounds = navigationController.navigationBar.bounds;
                    border.frame = CGRectMake(0, bounds.height - 2, bounds.width, 2)
        }
    }
    
}
