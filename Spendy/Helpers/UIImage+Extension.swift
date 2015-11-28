//
//  UIImage+Extension.swift
//  Spendy
//
//  Created by Dave Vo on 11/14/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import UIKit

extension UIImage {
  func imageWithColor(color1: UIColor) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
    
    let context =  UIGraphicsGetCurrentContext() as CGContextRef!
    CGContextTranslateCTM(context, 0, self.size.height)
    CGContextScaleCTM(context, 1.0, -1.0);
    //        CGContextSetBlendMode(context, kCGBlendModeNormal)
    CGContextSetBlendMode(context, CGBlendMode.Normal)
    
    let rect = CGRectMake(0, 0, self.size.width, self.size.height) as CGRect
    CGContextClipToMask(context, rect, self.CGImage)
    color1.setFill()
    CGContextFillRect(context, rect)
    
    let newImage = UIGraphicsGetImageFromCurrentImageContext() as UIImage
    UIGraphicsEndImageContext()
    
    return newImage
  }
}
