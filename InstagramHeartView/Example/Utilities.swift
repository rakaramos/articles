//
//  Utilities.swift
//  Example
//
//  Created by Wojciech Lukaszuk on 27/08/14.
//  Copyright (c) 2014 Wojtek Lukaszuk. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {

    class func imageWithColor(color: UIColor) -> UIImage
    {
        var rect = CGRectMake(0, 0, 1, 1)

        UIGraphicsBeginImageContext(rect.size)
        var context = UIGraphicsGetCurrentContext()

        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)

        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
}