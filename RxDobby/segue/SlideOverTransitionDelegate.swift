//
//  PresentModallyWithDirectionSegue.swift
//  Dobby
//
//  Created by ryan on 11/23/15.
//  Copyright © 2015 while1.io. All rights reserved.
//

import Foundation

// MARK: - 왼쪽에서 slide로 화면을 덮으면서 나타나는 transition delegate
final class LeftToRightSlideOverTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate, SizeHandlerHasableTransitionDelgate, PresentationControllerPositionDelegate, AnimatedTransitioningPositionDelegate {
    
    // presentationview 의 size 를 정의 합니다.
    var sizeHandler: ((parentSize: CGSize) -> CGSize)?
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        let presentationController = PresentationController(presentedViewController: presented, presentingViewController: presenting)
        presentationController.sizeHandler = self.sizeHandler
        presentationController.positionDelegate = self
        return presentationController
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = AnimatedTransitioning()
        animationController.isPresentation = true
        animationController.positionDelegate = self
        return animationController
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = AnimatedTransitioning()
        animationController.isPresentation = false
        animationController.positionDelegate = self
        return animationController
    }
    
    // MARK: - PresentationControllerPositionDelegate, AnimatedTransitioningPositionDelegate
    
    func positionForPresentedView(containerRect: CGRect, presentedRect: CGRect) -> CGPoint {
        return CGPointMake(0, 0)
    }
    
    func initialUpperViewPosition(finalFrameForUpper: CGRect) -> CGPoint {
        // 애니메이션 되기전에 시작 포인트 결정 (좌측 화면밖에서 시작하자)
        var point = finalFrameForUpper.origin
        point.x = -finalFrameForUpper.size.width
        return point
    }
}


// MARK: - 오른쪽에서 slide로 화면을 덮으면서 나타나는 transition delegate
final class RightToLeftSlideOverTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate, SizeHandlerHasableTransitionDelgate, PresentationControllerPositionDelegate, AnimatedTransitioningPositionDelegate {
    
    // presentationview 의 size 를 정의 합니다.
    var sizeHandler: ((parentSize: CGSize) -> CGSize)?
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        let presentationController = PresentationController(presentedViewController: presented, presentingViewController: presenting)
        presentationController.sizeHandler = self.sizeHandler
        presentationController.positionDelegate = self
        return presentationController
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = AnimatedTransitioning()
        animationController.isPresentation = true
        animationController.positionDelegate = self
        return animationController
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = AnimatedTransitioning()
        animationController.isPresentation = false
        animationController.positionDelegate = self
        return animationController
    }
    
    // MARK: - PresentationControllerPositionDelegate, AnimatedTransitioningPositionDelegate
    
    func positionForPresentedView(containerRect: CGRect, presentedRect: CGRect) -> CGPoint {
        let x = containerRect.size.width - presentedRect.size.width
        let y = containerRect.size.height - presentedRect.size.height
        return CGPoint(x: x, y: y)
    }
    
    func initialUpperViewPosition(finalFrameForUpper: CGRect) -> CGPoint {
        // 애니메이션 되기전에 시작 포인트 결정 (좌측 화면밖에서 시작하자)
        var point = finalFrameForUpper.origin
        point.x += finalFrameForUpper.size.width
        return point
    }
}



final class PresentationController: UIPresentationController, UIAdaptivePresentationControllerDelegate {
    var chromeView: UIView = UIView()   // 배경을 반투명하게 가리는 검정 배경
    var positionDelegate: PresentationControllerPositionDelegate?
    var sizeHandler: ((parentSize: CGSize) -> CGSize)?
    
    override init(presentedViewController: UIViewController, presentingViewController: UIViewController) {
        super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
        
        chromeView.backgroundColor = UIColor(white: 0.0, alpha: 0.4)
        chromeView.alpha = 0.0
        chromeView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(PresentationController.chromeViewTapped(_:))))
    }
    
    func chromeViewTapped(gesture: UIGestureRecognizer) {
        if(gesture.state == UIGestureRecognizerState.Ended) {
            presentingViewController.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func sizeForChildContentContainer(container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        // 기본적으로는 화면의 33% 할당, sizeHandler 지정되면 handler 에서 지정한 size 로 설정
        if let handler = self.sizeHandler {
            return handler(parentSize: parentSize)
        }
        let width = parentSize.width / 3.0
        return CGSizeMake(width, parentSize.height)
    }
    
    override func frameOfPresentedViewInContainerView() -> CGRect {
        var presentedViewFrame = CGRectZero
        if let containerBounds = containerView?.bounds {
            presentedViewFrame.size = self.sizeForChildContentContainer(self.presentedViewController, withParentContainerSize: containerBounds.size)
            if let positionDelegate = self.positionDelegate {
                presentedViewFrame.origin = positionDelegate.positionForPresentedView(containerBounds, presentedRect: presentedViewFrame)
            }
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


final class AnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    var isPresentation = false
    var positionDelegate: AnimatedTransitioningPositionDelegate?
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)   // 밑에 깔리는 vc
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)   // 나타날 vc
        let containerView = transitionContext.containerView()
        
        if let upperVC = self.isPresentation ? toVC : fromVC {
            let upperView = upperVC.view
            if self.isPresentation {
                containerView?.addSubview(upperView)
            }
            let finalFrameForUpperVC = transitionContext.finalFrameForViewController(upperVC)
            var initialFrameForUpperVC = finalFrameForUpperVC
            if let positionDelegate = self.positionDelegate {
                initialFrameForUpperVC.origin = positionDelegate.initialUpperViewPosition(finalFrameForUpperVC)
            }
            
            let initialFrameForUpper = isPresentation ? initialFrameForUpperVC : finalFrameForUpperVC
            let finalFrameForUpper = isPresentation ? finalFrameForUpperVC : initialFrameForUpperVC
            
            upperView.frame = initialFrameForUpper
            UIView.animateWithDuration(transitionDuration(transitionContext),
                delay: 0,
                usingSpringWithDamping: 300.0,
                initialSpringVelocity: 5.0,
                options: UIViewAnimationOptions.AllowUserInteraction,
                animations: { () -> Void in
                    upperView.frame = finalFrameForUpper
                },
                completion: { (value: Bool) -> Void in
                    if !self.isPresentation {
                        upperView.removeFromSuperview()
                    }
                    transitionContext.completeTransition(true)
            })
        }
    }
}