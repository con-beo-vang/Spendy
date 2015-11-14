//
//  TutorialViewController.swift
//  Spendy
//
//  Created by Dave Vo on 10/1/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import UIKit
import Presentation

let IDIOM = UI_USER_INTERFACE_IDIOM()
let IPAD = UIUserInterfaceIdiom.Pad

class TutorialViewController: PresentationController {
    
    var width = UIScreen.mainScreen().bounds.width
    var height = UIScreen.mainScreen().bounds.height
    
    struct BackgroundImage {
        let name: String
        let left: CGFloat
        let top: CGFloat
        let speed: CGFloat
        
        init(name: String, left: CGFloat, top: CGFloat, speed: CGFloat) {
            self.name = name
            self.left = left
            self.top = top
            self.speed = speed
        }
        
        func positionAt(index: Int) -> Position? {
            var position: Position?
            
            if index == 0 || speed != 0.0 {
                let currentLeft = left + CGFloat(index) * speed
                position = Position(left: currentLeft, top: top)
            }
            
            return position
        }
    }
    
    lazy var leftButton: UIBarButtonItem = { [unowned self] in
        let leftButton = UIBarButtonItem(
            title: "Previous",
            style: .Plain,
            target: self,
            action: "previous")
        
        leftButton.setTitleTextAttributes(
            [NSForegroundColorAttributeName : UIColor.blackColor()],
            forState: .Normal)
        
        return leftButton
        }()
    
    lazy var rightButton: UIBarButtonItem = { [unowned self] in
        let rightButton = UIBarButtonItem(
            title: "Skip",
            style: .Plain,
            target: self,
            action: "skipTutorial")
        
        rightButton.setTitleTextAttributes(
            [NSForegroundColorAttributeName : UIColor.blackColor()],
            forState: .Normal)
        
        return rightButton
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationTitle = false
        //        navigationItem.leftBarButtonItem = leftButton
                navigationItem.rightBarButtonItem = rightButton
        
        view.backgroundColor = UIColor(netHex: 0xFFBC00)
        
        configureSlides()
        configureBackground()
    }
    
    func skipTutorial() {
        print("skip tutorial")
    }
    
    // MARK: - Configuration
    
    func configureSlides() {
        var font = UIFont()
        if IDIOM == IPAD {
            font = UIFont.systemFontOfSize(34)
        } else {
            font = UIFont.systemFontOfSize(17)
        }
        let color = UIColor(netHex: 0xFFE8A9)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.Center
        
        let attributes = [NSFontAttributeName: font, NSForegroundColorAttributeName: color,
            NSParagraphStyleAttributeName: paragraphStyle]

        let screen1 = [
            "Quick Add on Home screen",
            "Pull down to open",
            "Pull up to close"
        ].joinWithSeparator("\n\n")

        let screen2 = [
            "Shortcuts on Accounts screen",
            "Drag and drop from one account to another to transfer!",
            "Swipe left to delete an account"
        ].joinWithSeparator("\n\n")

        let screen3 = [
            "When viewing an Account",
            "Swipe left to delete a transaction",
            "Swipe right to duplicate a transaction to today"
        ].joinWithSeparator("\n\n")

        let screen4 = [
            "Things you can do in Notification settings",
            "Pull down to create new a new reminder or a time slot",
            "Swipe left to delete a reminder or a time slot"
        ].joinWithSeparator("\n\n")

        let screen5 = [
            "Check us out at",
            "http://www.heyspendy.com"
        ].joinWithSeparator("\n\n")

        let titles = [
            screen1, screen2, screen3, screen4, screen5
        ].map { title -> Content in
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: width - 30, height: 200))
                label.numberOfLines = 7
                label.attributedText = NSAttributedString(string: title, attributes: attributes)
                label.textColor = UIColor.blackColor()
                let position = Position(left: 0.7, top: 0.35)
                
                return Content(view: label, position: position)
        }
        
        var slides = [SlideController]()
        
        for index in 0...4 {
            let controller = SlideController(contents: [titles[index]])
            controller.addAnimations([Content.centerTransitionForSlideContent(titles[index])])
            
            slides.append(controller)
        }
        
        add(slides)
    }
    
    func configureBackground() {
        var backgroundImages: [BackgroundImage]!
        
        if IDIOM == IPAD {
            backgroundImages = [
                BackgroundImage(name: "Tutorial_Trees_iPad", left: 0.0, top: 0.743, speed: -0.3),
                BackgroundImage(name: "Tutorial_Bus_iPad", left: 0.02, top: 0.77, speed: 0.25),
                BackgroundImage(name: "Tutorial_Truck_iPad", left: 1.3, top: 0.73, speed: -1.5),
                BackgroundImage(name: "Tutorial_Roadlines_iPad", left: 0.0, top: 0.79, speed: -0.24),
                BackgroundImage(name: "Tutorial_Houses_iPad", left: 0.0, top: 0.627, speed: -0.16),
                BackgroundImage(name: "Tutorial_Hills_iPad", left: 0.0, top: 0.51, speed: -0.08),
                BackgroundImage(name: "Tutorial_Mountains_iPad", left: 0.0, top: 0.29, speed: 0.0),
                BackgroundImage(name: "Tutorial_Clouds_iPad", left: -0.415, top: 0.14, speed: 0.18),
                BackgroundImage(name: "Tutorial_Sun_iPad", left: 0.8, top: 0.07, speed: 0.0)
            ]
        } else {
            backgroundImages = [
                BackgroundImage(name: "Tutorial_Trees", left: 0.0, top: 0.77, speed: -0.3),
                BackgroundImage(name: "Tutorial_Bus", left: 0.02, top: 0.79, speed: 0.25),
                BackgroundImage(name: "Tutorial_Truck", left: 1.3, top: 0.73, speed: -1.5),
                BackgroundImage(name: "Tutorial_Roadlines", left: 0.0, top: 0.77, speed: -0.24),
                BackgroundImage(name: "Tutorial_Houses", left: 0.0, top: 0.624, speed: -0.16),
                BackgroundImage(name: "Tutorial_Hills", left: 0.0, top: 0.51, speed: -0.08),
                BackgroundImage(name: "Tutorial_Mountains", left: 0.0, top: 0.29, speed: 0.0),
                BackgroundImage(name: "Tutorial_Clouds", left: -0.415, top: 0.14, speed: 0.18),
                BackgroundImage(name: "Tutorial_Sun", left: 0.8, top: 0.07, speed: 0.0)
            ]
        }
        
        var contents = [Content]()
        
        for backgroundImage in backgroundImages {
            let imageView = UIImageView(image: UIImage(named: backgroundImage.name))
            if let position = backgroundImage.positionAt(0) {
                contents.append(Content(view: imageView, position: position, centered: false))
            }
        }
        
        addToBackground(contents)
        
        let skipButton = UIButton(frame: CGRect(x: 10, y: 30, width: 50, height: 20))
        skipButton.setTitle("Skip", forState: UIControlState.Normal)
        skipButton.addTarget(self, action: "onSkip:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(skipButton)
        
        for row in 1...4 {
            for (column, backgroundImage) in backgroundImages.enumerate() {
                if let position = backgroundImage.positionAt(row), content = contents.at(column) {
                    addAnimation(TransitionAnimation(content: content, destination: position,
                        duration: 2.0, dumping: 1.0), forPage: row)
                }
            }
        }
        
        let groundView = UIView(frame: CGRect(x: 0, y: 0, width: 1024, height: 100))
        groundView.backgroundColor = UIColor(netHex: 0xFFCD41)
        let groundContent = Content(view: groundView,
            position: Position(left: 0.0, bottom: 0.1), centered: false)
        contents.append(groundContent)
        
        addToBackground([groundContent])
    }
    
    func onSkip(sender: UIButton) {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "GotTutorial")
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension Array {
    
    func at(index: Int?) -> Element? {
        var object: Element?
        if let index = index where index >= 0 && index < endIndex {
            object = self[index]
        }
        
        return object
    }
}