//
//  CustomPresentAnimationController.swift
//  CustomTransitions
//
//  Created by Joyce Echessa on 3/3/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import UIKit

enum CustomSegueAnimation {
    case Push
    case SwipeDown
    case GrowScale
    case CornerRotate
    case Mixed
}

class CustomPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    var animationType = CustomSegueAnimation.Push
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 2.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        let containerView = transitionContext.containerView()
        let screenBounds = UIScreen.mainScreen().bounds
        
        
        switch animationType {
        case CustomSegueAnimation.Push:
            let finalToFrame = screenBounds
            let finalFromFrame = CGRectOffset(finalToFrame, -screenBounds.size.width, 0)
            
            toViewController.view.frame = CGRectOffset(finalToFrame, screenBounds.size.width, 0)
            containerView?.addSubview(toViewController.view)
            
            UIView.animateWithDuration(0.5, animations: {
                toViewController.view.frame = finalToFrame
                fromViewController.view.frame = finalFromFrame
                }, completion: {
                    finished in
                    transitionContext.completeTransition(true)
            })
            break
            
        case CustomSegueAnimation.SwipeDown:
            let finalToFrame = screenBounds
            let finalFromFrame = CGRectOffset(finalToFrame, 0, screenBounds.size.height)
            
            toViewController.view.frame = CGRectOffset(finalToFrame, 0, -screenBounds.size.height)
            containerView?.addSubview(toViewController.view)
            
            UIView.animateWithDuration(0.5, animations: {
                toViewController.view.frame = finalToFrame
                fromViewController.view.frame = finalFromFrame
                }, completion: {
                    finished in
                    transitionContext.completeTransition(true)
            })
            break
            
        case CustomSegueAnimation.GrowScale:
            let originalCenter = fromViewController.view.center
            toViewController.view.transform = CGAffineTransformMakeScale(0.05, 0.05)
            toViewController.view.center = originalCenter
            
            containerView?.addSubview(toViewController.view)
            
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                toViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
                }, completion: {
                    finished in
                    transitionContext.completeTransition(true)
            })
            break
            
        case CustomSegueAnimation.CornerRotate:
            toViewController.view.layer.anchorPoint = CGPointZero
            fromViewController.view.layer.anchorPoint = CGPointZero
            
            toViewController.view.layer.position = CGPointZero
            fromViewController.view.layer.position = CGPointZero
            
            let containerView: UIView? = fromViewController.view.superview
            toViewController.view.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
            containerView?.addSubview(toViewController.view)
            
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: UIViewAnimationOptions.TransitionNone, animations: {
                fromViewController.view.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
                toViewController.view.transform = CGAffineTransformIdentity
                }, completion: {
                    finished in
                    transitionContext.completeTransition(true)
            })
            break
            
        case CustomSegueAnimation.Mixed:
            let finalFrameForVC = transitionContext.finalFrameForViewController(toViewController)
            toViewController.view.frame = CGRectOffset(finalFrameForVC, 0, -screenBounds.size.height)
            containerView!.addSubview(toViewController.view)
            
            UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: .CurveLinear, animations: {
                fromViewController.view.alpha = 0.5
                toViewController.view.frame = finalFrameForVC
                }, completion: {
                    finished in
                    transitionContext.completeTransition(true)
                    fromViewController.view.alpha = 1.0
            })
            break
        }
        
        

        
    }
    
}
