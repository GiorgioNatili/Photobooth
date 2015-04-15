//
//  Color.swift
//  Photobooth
//
//  Created by Gareth on 4/14/15.
//  Copyright (c) 2015 Matt Donnelly. All rights reserved.
//

import Foundation
import UIKit

func colorWithHexString (hex:String) -> UIColor {
    var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
    
    if (cString.hasPrefix("#")) {
        cString = cString.substringFromIndex(1)
    }
    
    if (countElements(cString) != 6) {
        return UIColor.grayColor()
    }
    
    var rString = cString.substringToIndex(2)
    var gString = cString.substringFromIndex(2).substringToIndex(2)
    var bString = cString.substringFromIndex(4).substringToIndex(2)
    
    var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
    NSScanner.scannerWithString(rString).scanHexInt(&r)
    NSScanner.scannerWithString(gString).scanHexInt(&g)
    NSScanner.scannerWithString(bString).scanHexInt(&b)
    
    return UIColor(red: Float(r) / 255.0, green: Float(g) / 255.0, blue: Float(b) / 255.0, alpha: Float(1))
}
