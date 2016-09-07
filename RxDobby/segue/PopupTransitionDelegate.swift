//
//  PopupTransitionDelegate.swift
//  Dobby
//
//  Created by ryan on 1/5/16.
//  Copyright © 2016 while1.io. All rights reserved.
//

import Foundation


final class PopupTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate, SizeHandlerHasableTransitionDelgate {
    
    // presentationview 의 size 를 정의 합니다.
    var sizeHandler: ((parentSize: CGSize) -> CGSize)?
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        let presentationController = PopupPresentationController(presentedViewController: presented, presentingViewController: presenting)
        presentationController.sizeHandler = self.sizeHandler
        return presentationController
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = PopupAnimatedTransitioning()
        animationController.isPresentation = true
        return animationController
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = PopupAnimatedTransitioning()
        animationController.isPresentation = false
        return animationController
    }
}

final class PopupPresentationController: UIPresentationController, UIAdaptivePresentationControllerDelegate {
    var chromeView: UIView = UIView()   // 배경을 반투명하게 가리는 검정 배경
    var sizeHandler: ((parentSize: CGSize) -> CGSize)?
    
    override init(presentedViewController: UIViewController, presentingViewController: UIViewController) {
        super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
        
        chromeView.backgroundColor = UIColor(white: 0.0, alpha: 0.4)
        chromeView.alpha = 0.0
        chromeView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(PopupPresentationController.chromeViewTapped(_:))))
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PopupPresentationController.keyboardNotification(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo,
            let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            
            // 키보드가 노출 여부가 화면사이즈에 영향을 미치게 합니다.
            containerView?.frame.size.height = keyboardEndFrame.origin.y
        }
    }
    
    func chromeViewTapped(gesture: UIGestureRecognizer) {
        if(gesture.state == UIGestureRecognizerState.Ended) {
            presentedViewController.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func sizeForChildContentContainer(container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        // 기본적으로는 화면의 80% 할당, sizeHandler 지정되면 handler 에서 지정한 size 로 설정
        if let handler = self.sizeHandler {
            return handler(parentSize: parentSize)
        }
        let width = parentSize.width * 0.8
        let height = parentSize.height * 0.8
        return CGSizeMake(width, height)
    }
    
    override func frameOfPresentedViewInContainerView() -> CGRect {
        var presentedViewFrame = CGRectZero
        if let containerBounds = containerView?.bounds {
            presentedViewFrame.size = sizeForChildContentContainer(self.presentedViewController, withParentContainerSize: containerBounds.size)
            // 화면 중앙에 위치
            presentedViewFrame.origin = CGPointMake(
                (containerBounds.width - presentedViewFrame.size.width) / 2,
                (containerBounds.height - presentedViewFrame.size.height) / 2)
        }
        return presentedViewFrame
    }
    
    override func presentationTransitionWillBegin() {
        if let containerView = self.containerView {
            chromeView.frame = containerView.bounds
            chromeView.alpha = 0.0
            containerView.insertSubview(chromeView, atIndex: 0)
            if let coordinator = presentedViewController.transitionCoordinator() {
                coordinator.animateAlongsideTransition({ (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
                    self.chromeView.alpha = 1.0
                    }, completion: nil)
            } else {
                self.chromeView.alpha = 1.0
            }
        }
        
        if let presented = presentedView() {
            presented.alpha = 0.0
        }
    }
    
    override func dismissalTransitionWillBegin() {
        if let coordinator = presentedViewController.transitionCoordinator() {
            coordinator.animateAlongsideTransition({ (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
                self.chromeView.alpha = 0.0
                }, completion: nil)
        } else {
            self.chromeView.alpha = 0.0
        }
    }
    
    override func containerViewWillLayoutSubviews() {
        if let bounds = containerView?.bounds {
            chromeView.frame = bounds
        }
        presentedView()?.frame = self.frameOfPresentedViewInContainerView()
    }
    
    override func shouldPresentInFullscreen() -> Bool {
        return true
    }
    
    override func adaptivePresentationStyle() -> UIModalPresentationStyle {
        return UIModalPresentationStyle.FullScreen
    }
}


final class PopupAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    var isPresentation = false
    var positionDelegate: AnimatedTransitioningPositionDelegate?
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView()
        let screens: (from:UIViewController, to:UIViewController) = (
            transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!,
            transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!)
        
        let tedVC = self.isPresentation ? screens.to : screens.from
        //let tingVC = self.isPresentation ? screens.from : screens.to
        
        containerView?.addSubview(tedVC.view)
        
        UIView.animateWithDuration(transitionDuration(transitionContext),
            delay: 0,
            usingSpringWithDamping: 300.0,
            initialSpringVelocity: 5.0,
            options: UIViewAnimationOptions.AllowUserInteraction,
            animations: { () -> Void in
                if self.isPresentation {
                    tedVC.view.alpha = 1.0
                } else {
                    tedVC.view.alpha = 0.0
                }
            },
            completion: { (value: Bool) -> Void in
                if !self.isPresentation {
                    tedVC.view.removeFromSuperview()
                }
                transitionContext.completeTransition(true)
        })
    }
}