//
//  CustomDismissAnimationController.swift
//  CustomTransitions
//
//  Created by Joyce Echessa on 3/3/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import UIKit

class CustomDismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
  
  var animationType = CustomSegueAnimation.Push
  
  func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
    return 2
  }
  
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
    let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
    
    let containerView = transitionContext.containerView()
    let screenBounds = UIScreen.mainScreen().bounds
    
    
    switch animationType {
    case CustomSegueAnimation.Push:
      let finalToFrame = screenBounds
      let finalFromFrame = CGRectOffset(finalToFrame, screenBounds.size.width, 0)
      
      toViewController.view.frame = CGRectOffset(finalToFrame, -screenBounds.size.width, 0)
      containerView?.addSubview(toViewController.view)
      
      UIView.animateWithDuration(0.5, animations: {
        toViewController.view.frame = finalToFrame
        fromViewController.view.frame = finalFromFrame
        }, completion: {
          finished in
          transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
      })
      break
      
    case CustomSegueAnimation.SwipeDown:
      let finalToFrame = screenBounds
      let finalFromFrame = CGRectOffset(finalToFrame, 0, -screenBounds.size.height)
      
      toViewController.view.frame = CGRectOffset(finalToFrame, 0, screenBounds.size.height)
      containerView?.addSubview(toViewController.view)
      
      UIView.animateWithDuration(0.5, animations: {
        toViewController.view.frame = finalToFrame
        fromViewController.view.frame = finalFromFrame
        }, completion: {
          finished in
          transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
      })
      break
      
    case CustomSegueAnimation.GrowScale:
      fromViewController.view.superview?.insertSubview(toViewController.view, atIndex: 0)
      
      UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
        fromViewController.view.transform = CGAffineTransformMakeScale(0.05, 0.05)
        }, completion: {
          finished in
          transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
      })
      break
      
    case CustomSegueAnimation.CornerRotate:
      toViewController.view.layer.anchorPoint = CGPointZero
      fromViewController.view.layer.anchorPoint = CGPointZero
      
      toViewController.view.layer.position = CGPointZero
      fromViewController.view.layer.position = CGPointZero
      
      let containerView = fromViewController.view.superview
      containerView?.addSubview(toViewController.view)
      
      UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: UIViewAnimationOptions.TransitionNone, animations: {
        fromViewController.view.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
        toViewController.view.transform = CGAffineTransformIdentity
        }, completion: {
          finished in
          transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
      })
      break
      
    case CustomSegueAnimation.Mixed:
      let finalFrameForVC = transitionContext.finalFrameForViewController(toViewController)
      let containerView = transitionContext.containerView()
      toViewController.view.frame = finalFrameForVC
      toViewController.view.alpha = 0.5
      containerView!.addSubview(toViewController.view)
      containerView!.sendSubviewToBack(toViewController.view)
      
      let snapshotView = fromViewController.view.snapshotViewAfterScreenUpdates(false)
      snapshotView.frame = fromViewController.view.frame
      containerView!.addSubview(snapshotView)
      
      fromViewController.view.removeFromSuperview()
      
      UIView.animateWithDuration(transitionDuration(transitionContext), animations: {
        snapshotView.frame = CGRectInset(fromViewController.view.frame, fromViewController.view.frame.size.width / 2, fromViewController.view.frame.size.height / 2)
        toViewController.view.alpha = 1.0
        }, completion: {
          finished in
          snapshotView.removeFromSuperview()
          transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
      })
      break
    }
  }
  
}
