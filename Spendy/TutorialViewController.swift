//
//  TutorialViewController.swift
//  Spendy
//
//  Created by Dave Vo on 10/1/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import UIKit
import Presentation

// TutorialViewController

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
//        let font = UIFont(name: "HelveticaNeue", size: 17.0)!
        let font = UIFont.systemFontOfSize(17)
        let color = UIColor(netHex: 0xFFE8A9)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.Center
        
        let attributes = [NSFontAttributeName: font, NSForegroundColorAttributeName: color,
            NSParagraphStyleAttributeName: paragraphStyle]
        
        let titles = [
            "At Home page \n\n Pull down to open Quick add mode. \n\n Then pull up to close",
            "At Account page \n\n Drag an account to another to transfer money between 2 accounts \n\n Swipe left to delete account",
            "At Account's detail page \n\n Swipe left to delete transacion \n\n Swipe right to dupplicate this transaction to today",
            "At Notification settings \n\n Pull down to create new reminder or new time slot \n\n Swipe lef to delete reminder or time slots",
            "http://cheetah.com"].map { title -> Content in
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: width - 30, height: 200))
                label.numberOfLines = 6
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
        let backgroundImages = [
            BackgroundImage(name: "Trees", left: 0.0, top: 0.743, speed: -0.3),
            BackgroundImage(name: "Bus", left: 0.02, top: 0.77, speed: 0.25),
            BackgroundImage(name: "Truck", left: 1.3, top: 0.73, speed: -1.5),
            BackgroundImage(name: "Roadlines", left: 0.0, top: 0.79, speed: -0.24),
            BackgroundImage(name: "Houses", left: 0.0, top: 0.627, speed: -0.16),
            BackgroundImage(name: "Hills", left: 0.0, top: 0.51, speed: -0.08),
            BackgroundImage(name: "Mountains", left: 0.0, top: 0.29, speed: 0.0),
            BackgroundImage(name: "Clouds", left: -0.415, top: 0.14, speed: 0.18),
            BackgroundImage(name: "Sun", left: 0.8, top: 0.07, speed: 0.0)
        ]
        
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
        
        let groundView = UIView(frame: CGRect(x: 0, y: 0, width: 1024, height: 60))
        groundView.backgroundColor = UIColor(netHex: 0xFFCD41)
        let groundContent = Content(view: groundView,
            position: Position(left: 0.0, bottom: 0.063), centered: false)
        contents.append(groundContent)
        
        addToBackground([groundContent])
    }
    
    func onSkip(sender: UIButton) {
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