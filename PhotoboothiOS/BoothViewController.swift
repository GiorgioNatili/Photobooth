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
        
        // Change the border to blue
        let navHeight = self.navigationController?.navigationBar.frame.height
        let navWidth = self.navigationController?.navigationBar.frame.width
        var navBorder = UIView(frame: CGRectMake(0, navHeight! - 2, navWidth!, 2))
        navBorder.backgroundColor = UIColor(rgba: "#5EA9DD")
        self.navigationController?.navigationBar.addSubview(navBorder)
        
        // Append image to the navigation bar
        let logoView = UIImageView(frame: CGRectMake(0, 0, 30, 30))
        logoView.image = UIImage(named: "TwitterLogo")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        logoView.contentMode = UIViewContentMode.ScaleAspectFit
        logoView.frame.origin.x = 10
        logoView.frame.origin.y = 8
        navbar.titleView = logoView
        
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
    
}
