//
//  SplashViewController.swift
//  Spendy
//
//  Created by Dave Vo on 10/3/15.
//  Copyright © 2015 Cheetah. All rights reserved.
//

import UIKit
import CBZSplashView

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let icon = UIImage(named: "Cheetah-1")
        let splashView = CBZSplashView(icon: icon, backgroundColor: Color.strongColor)
        
        view.addSubview(splashView)
        
        splashView.animationDuration = 1.5
        
        splashView.startAnimationWithCompletionHandler { () -> Void in
            
            let user = User.current()
            
            // TODO: check login
            let isLoggedIn = user != nil
            
            if isLoggedIn {
                // Go to Home screen
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("RootTabBarController") as! RootTabBarController
                self.presentViewController(vc, animated: true, completion: nil)
            } else {
                // Go to Login screen
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
                self.presentViewController(vc, animated: true, completion: nil)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
