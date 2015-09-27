//
//  Color.swift
//  Spendy
//
//  Created by Dave Vo on 9/27/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import UIKit

class Color: NSObject {
    
    static var strongColor = UIColor(netHex: 0xE6A447)
    //    static var extremeDarkColor = UIColor(netHex: 0xC48853)
    //    static var darkColor = UIColor(netHex: 0xC69B46)
    //    static var extremeLightColor = UIColor(netHex: 0xFAEED0)
    //    static var lightColor = UIColor(netHex: 0xF0E1B6)
    
    static var logoColor = UIColor(netHex: 0xE6A447) // strong color
    static var appNameColor = UIColor(netHex: 0xB38537)
    static var loginBackgroundColor = UIColor(netHex: 0xFAEED0) // extreme light color
    static var loginButtonBackgroundColor = UIColor(netHex: 0xFCC96F)
    static var registerColor = UIColor(netHex: 0xC48853) // extreme dark color
    static var forgotPasswordColor = UIColor(netHex: 0xE6A447) // strong color
    
    
    static var navigationBarColor = UIColor(netHex: 0xFFC670)
    static var tabBarColor = UIColor(netHex: 0xE6A447) // strong color
    
    static var lightStatusColor = UIColor(netHex: 0xEED9BD)
    static var darkStatusColor = UIColor(netHex: 0xC69B46) // dark color
    static var dateHomeColor = UIColor(netHex: 0xC78A44)
    
    static var popupHeaderColor = UIColor(netHex: 0xFAC561)
    static var popupBackgroundColor = UIColor(netHex: 0xF0E1B6) // light color
    static var popupFromColor = UIColor(netHex: 0xC29D00)
    static var popupDateColor = UIColor(netHex: 0xC37F21)
    static var popupButtonColor = UIColor(netHex: 0x9F5500)
    static var popupShadowColor = UIColor(netHex: 0xD99652)
    
    static var quickCategoryColor = UIColor(netHex: 0xE6A447) // strong color
    static var quickSegmentColor = UIColor(netHex: 0xC48853) // extreme dark color
    
    static var originalAccountColor = UIColor(netHex: 0xFAEED0) // extreme light color
    static var destinationAccountColor = UIColor(netHex: 0xBFA680)
    
    static var moreDetailColor = UIColor(netHex: 0xC69B46)  // dark color
    static var switchColor = UIColor(netHex: 0xE6A447) // strong color
    
    
    
    
    
    
    static var incomeColor = UIColor(netHex: 0x3D8B37)
    static var expenseColor = UIColor(netHex: 0xCA2437)
    static var balanceColor = UIColor(netHex: 0x4682B4)
    
    static var isGreen: Bool {
        get {
        return self.isGreen
        }
        set {
            self.isGreen = newValue
            if newValue {
                strongColor = UIColor(netHex: 0xE6A447)
                
                logoColor = strongColor
                appNameColor = UIColor(netHex: 0xB38537)
                loginBackgroundColor = UIColor(netHex: 0xFAEED0) // extreme light color
                loginButtonBackgroundColor = UIColor(netHex: 0xFCC96F)
                registerColor = UIColor(netHex: 0xC48853) // extreme dark color
                forgotPasswordColor = strongColor
                
                
                navigationBarColor = strongColor
                tabBarColor = strongColor
                
                lightStatusColor = UIColor(netHex: 0xEED9BD)
                darkStatusColor = UIColor(netHex: 0xC69B46) // dark color
                dateHomeColor = UIColor(netHex: 0xC78A44)
                
                popupHeaderColor = UIColor(netHex: 0xFAC561)
                popupBackgroundColor = UIColor(netHex: 0xF0E1B6) // light color
                popupFromColor = UIColor(netHex: 0xC29D00)
                popupDateColor = UIColor(netHex: 0xC37F21)
                popupButtonColor = UIColor(netHex: 0x9F5500)
                popupShadowColor = UIColor(netHex: 0xD99652)
                
                quickCategoryColor = strongColor
                quickSegmentColor = UIColor(netHex: 0xC48853) // extreme dark color
                
                originalAccountColor = UIColor(netHex: 0xFAEED0) // extreme light color
                destinationAccountColor = UIColor(netHex: 0xBFA680)
                
                moreDetailColor = UIColor(netHex: 0xC69B46)  // dark color
                switchColor = strongColor
            }
        }
    }
    
}
