//
//  CustomSegmentedControl.swift
//  Spendy
//
//  Created by Dave Vo on 9/16/15.
//  Copyright (c) 2015 Cheetah. All rights reserved.
//

import UIKit

class CustomSegmentedControl: UISegmentedControl {

    var oldValue : Int!
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.oldValue = self.selectedSegmentIndex
        super.touchesBegan( touches , withEvent: event )
    }
    
    // This was the key to make it work as expected
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesEnded( touches , withEvent: event )
        
        if self.oldValue == self.selectedSegmentIndex
        {
            sendActionsForControlEvents(UIControlEvents.ValueChanged)
        }
    }
}
