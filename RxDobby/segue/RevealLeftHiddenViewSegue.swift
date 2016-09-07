//
//  DSegue+RevealTransition.swift
//  Dobby
//
//  Created by ryan on 9/14/15.
//  Copyright (c) 2015 while1.io. All rights reserved.
//

import Foundation

protocol RevealPresentationPositionDelegate {
    func positionForPresentedView(containerRect: CGRect, presentedSize: CGSize) -> CGPoint
    func boundaryCollisionCheck(presented: CGRect, presenting: CGRect, container: CGRect, delta :CGPoint) -> Bool
}

protocol AnimatedRevealTransitioningPositionDelegate {
    func finalPositionForPresentingView(containerRect: CGRect, presentedRect: CGRect) -> CGPoint
}


final class RevealLeftHiddenViewSegue: UIStoryboardSegue {
    
    private var transitionDelegate: UIViewControllerTransitioningDelegate?
    
    var direction: DSegueDirection?
    var sizeHandler: SizeHandlerFunc?
    
    override func perform() {
        guard let direction = direction else {
            return
        }
        switch direction {
        case .LeftToRight:
            self.transitionDelegate = RevealTransitionDelegate()
        case .RightToLeft:
            //self.transitionDelegate = RightToLeftSlideForHiddenTransitionDelegate()
            print("later")
        }
        if var trans = self.transitionDelegate as? SizeHandlerHasableTransitionDelgate {
            trans.sizeHandler = sizeHandler
        }
        destinationViewController.modalPresentationStyle = .Custom
        destinationViewController.transitioningDelegate = self.transitionDelegate
        sourceViewController.presentViewController(destinationViewController, animated: true, completion: nil)
    }
}

extension RevealLeftHiddenViewSegue {
    
    // MARK: - 왼쪽에서 시작하는 기존 container view를 slide로 밀면서 나타나는 transition
    final class RevealTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate, SizeHandlerHasableTransitionDelgate, RevealPresentationPositionDelegate, AnimatedRevealTransitioningPositionDelegate {
        
        var sizeHandler: ((parentSize: CGSize) -> CGSize)? // SizeHandlerHasableTransitionDelgate
        
        func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
            let presentationController = RevealPresentationController(presentedViewController: presented, presentingViewController: presenting)
            presentationController.sizeHandler = self.sizeHandler
            presentationController.positionDelegate = self
            return presentationController
        }
        
        func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            let animationController = AnimatedRevealTransitioning()
            animationController.isPresentation = true
            animationController.positionDelegate = self
            return animationController
        }
        
        func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            let animationController = AnimatedRevealTransitioning()
            animationController.isPresentation = false
            animationController.positionDelegate = self
            return animationController
        }
        
        // MARK: - RevealPresentationPositionDelegate
        func positionForPresentedView(containerRect: CGRect, presentedSize: CGSize) -> CGPoint {
            return CGPointMake(0, 0)    // 보통 메뉴는 좌측 상단이 원점
        }
        func boundaryCollisionCheck(presented: CGRect, presenting: CGRect, container: CGRect, delta :CGPoint) -> Bool {
            var size = presented.size
            if let handler = self.sizeHandler {
                size = handler(parentSize: container.size)
            }
            
            if size.width < presenting.origin.x + delta.x {
                return true
            }
            if presenting.origin.x + delta.x < 0 {
                return true
            }
            return false
        }
        
        // MARK: - AnimatedRevealTransitioningPositionDelegate
        func finalPositionForPresentingView(containerRect: CGRect, presentedRect: CGRect) -> CGPoint {
            // 보통 기존 contents 영역의 view 는 좌측 메뉴가 열렸을때 좌측메뉴 너비의 x 좌표에 위치함
            if let handler = self.sizeHandler {
                let size = handler(parentSize: containerRect.size)
                let pos = CGPointMake(size.width, 0)
                return pos
            }
            return containerRect.origin
        }
    }
    
    // MARK: - RevealPresentationController
    final class RevealPresentationController: UIPresentationController, UIAdaptivePresentationControllerDelegate {
        var chromeView: UIView = UIView()   // 배경을 반투명하게 가리는 검정 배경
        var orgPresentingSuperview: UIView?
        var positionDelegate: RevealPresentationPositionDelegate?
        var sizeHandler: ((parentSize: CGSize) -> CGSize)?
        
        override init(presentedViewController: UIViewController, presentingViewController: UIViewController) {
            super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
            chromeView.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
            chromeView.alpha = 0.0
            chromeView.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(RevealPresentationController.chromeViewTapped(_:))))
            chromeView.addGestureRecognizer(
                UIPanGestureRecognizer(target: self, action: #selector(RevealPresentationController.chromeViewPanned(_:))))
        }
        
        func chromeViewTapped(gesture: UIGestureRecognizer) {
            if(gesture.state == UIGestureRecognizerState.Ended) {
                presentingViewController.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
        var oldTransform = CGAffineTransformIdentity
        func chromeViewPanned(recognizer: UIPanGestureRecognizer) {
            let presentingView = self.presentingViewController.view
            let presentedView = self.presentedViewController.view
            let leftToRight = (recognizer.velocityInView(presentingView).x > 0)
            switch recognizer.state {
            case .Began:
                oldTransform = presentingView.transform
            case .Changed:
                let deltaX = recognizer.translationInView(presentingView).x
                if let positionDelegate = self.positionDelegate {
                    let collision = positionDelegate.boundaryCollisionCheck(presentedView.frame, presenting: presentingView.frame, container: containerView!.frame, delta: CGPointMake(deltaX, 0))
                    if collision {
                        break
                    }
                }
                presentingView.transform = CGAffineTransformMakeTranslation(presentingView.frame.origin.x + deltaX, 0)
                recognizer.setTranslation(CGPointZero, inView: presentingView)
            case .Ended:
                if !leftToRight {
                    presentingViewController.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    // 처음 위치로 되돌아감
                    UIView.animateWithDuration(0.5,
                        delay: 0,
                        usingSpringWithDamping: 1.0,
                        initialSpringVelocity: 0,
                        options: .CurveEaseInOut,
                        animations: {
                            presentingView.transform = self.oldTransform
                        },
                        completion: nil)
                }
            default:
                break
            }
        }
        
        override func presentationTransitionWillBegin() {
            
            chromeView.frame = self.presentingViewController.view.frame
            chromeView.alpha = 1.0
            if let orgPresentingSuperview = presentingViewController.view.superview {
                self.orgPresentingSuperview = orgPresentingSuperview
            }
            presentingViewController.view.addSubview(chromeView)
            containerView?.addSubview(presentedViewController.view)
            containerView?.addSubview(presentingViewController.view)
            
            presentingViewController.view.layer.shadowOpacity = 0.8
        }
        
        override func dismissalTransitionDidEnd(completed: Bool) {
            if !completed {
                return
            }
            // view hierarchy rollback
            presentingViewController.view.layer.shadowOpacity = 0.0
            chromeView.removeFromSuperview()
            presentingViewController.view.removeFromSuperview()
            presentedView()?.removeFromSuperview()
            if let superview = self.orgPresentingSuperview {
                superview.addSubview(presentingViewController.view)
            }
        }
        
        override func containerViewWillLayoutSubviews() {
            self.containerView?.bringSubviewToFront(self.presentingViewController.view)
        }
        
        override func shouldPresentInFullscreen() -> Bool {
            return true
        }
        
        override func adaptivePresentationStyle() -> UIModalPresentationStyle {
            return UIModalPresentationStyle.FullScreen
        }
    }
    
    final class AnimatedRevealTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
        var isPresentation = false
        var positionDelegate: AnimatedRevealTransitioningPositionDelegate?
        
        func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
            return 0.5
        }
        
        func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
            let containerView = transitionContext.containerView()
            let screens: (from:UIViewController, to:UIViewController) = (
                transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!,
                transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!)
            
            let tedVC = self.isPresentation ? screens.to : screens.from
            let tingVC = self.isPresentation ? screens.from : screens.to
            
            var openTargetPosX:CGFloat = 0.0
            if let positionDelegate = self.positionDelegate, let containerView = containerView {
                let pos = positionDelegate.finalPositionForPresentingView(containerView.frame, presentedRect: tedVC.view.frame)
                openTargetPosX = pos.x
            }
            
            UIView.animateWithDuration(transitionDuration(transitionContext),
                delay: 0,
                usingSpringWithDamping: 300.0,
                initialSpringVelocity: 5.0,
                options: UIViewAnimationOptions.AllowUserInteraction,
                animations: { () -> Void in
                    if self.isPresentation {
                        tingVC.view.transform = CGAffineTransformMakeTranslation(openTargetPosX, 0)
                    } else {
                        tingVC.view.transform = CGAffineTransformIdentity
                    }
                },
                completion: { (value: Bool) -> Void in
                    if !self.isPresentation {
                    }
                    transitionContext.completeTransition(true)
            })
        }
    }
}