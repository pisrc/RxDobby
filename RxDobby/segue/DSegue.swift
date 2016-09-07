import UIKit

public typealias SizeHandlerFunc = (parentSize: CGSize) -> CGSize

public enum DSegueStyle {
    case Show(animated: Bool)           // Push
    case ShowDetail(animated: Bool)     // 화면 전환
    case PresentModally(animated: Bool) // Modal
    case PresentModallyWithDirection(DSegueDirection, sizeHandler: SizeHandlerFunc)
    case PresentPopup(sizeHandler: SizeHandlerFunc)
    case PresentAsPopover
    case Embed(containerView: UIView?)
}

public enum DSegueDirection {
    case LeftToRight
    case RightToLeft
}

protocol AnimatedSettable {
    var animated: Bool { get set }
}

protocol PresentationControllerPositionDelegate {
    func positionForPresentedView(containerRect: CGRect, presentedRect: CGRect) -> CGPoint
}

protocol SizeHandlerHasableTransitionDelgate {
    var sizeHandler: ((parentSize: CGSize) -> CGSize)? { get set }
}

protocol AnimatedTransitioningPositionDelegate {
    // animation 시작 되기 전의 초기 위치를 결정해주세요. 해당 위치부터 presentation에 명시한 위치까지 애니메이션 됩니다.
    func initialUpperViewPosition(finalFrameForUpper: CGRect) -> CGPoint
}


public struct DSegue {
    
    public typealias Destination = () -> UIViewController
    public typealias Style = () -> DSegueStyle
    public let source: UIViewController
    private let destination: Destination
    private let style: Style
    
    private var transitionDelegate: UIViewControllerTransitioningDelegate?
    
    public init(source: UIViewController, destination: Destination, style: Style) {
        self.source = source
        self.destination = destination
        self.style = style
        
        // self.segue 를 만들어야 합니다.
        switch style() {
        case .Show(_):
            transitionDelegate = nil
        case .ShowDetail(_):
            transitionDelegate = nil
        case .PresentModally(_):
            transitionDelegate = nil
        case .PresentModallyWithDirection(let direction, _) :
            switch direction {
            case .LeftToRight:
                transitionDelegate = LeftToRightSlideOverTransitionDelegate()
            case .RightToLeft:
                transitionDelegate = RightToLeftSlideOverTransitionDelegate()
            }
        case .PresentPopup(_):
            transitionDelegate = nil
        case .PresentAsPopover:
            transitionDelegate = nil
        case .Embed(_):
            transitionDelegate = nil
        }
    }
    
    private func getSegue(destination: UIViewController, style: DSegueStyle) -> UIStoryboardSegue? {
        
        var segue: UIStoryboardSegue?
        
        switch style {
        case .Show(let animated):
            
            segue = ShowSegue(identifier: nil, source: source, destination: destination)
            if var segue = segue as? AnimatedSettable {
                segue.animated = animated
            }
            
        case .ShowDetail(let animated):
            
            segue = ShowDetailSegue(identifier: nil, source: source, destination: destination)
            if var segue = segue as? AnimatedSettable {
                segue.animated = animated
            }
            
        case .PresentModally(let animated):
            segue = PresentModallySegue(identifier: nil, source: source, destination: destination)
            if var segue = segue as? AnimatedSettable {
                segue.animated = animated
            }
            
        case .PresentModallyWithDirection(_, let sizeHandler) :
            destination.modalPresentationStyle = .Custom
            destination.transitioningDelegate = transitionDelegate
            if var transitioningDelegate = self.transitionDelegate as? SizeHandlerHasableTransitionDelgate {
                transitioningDelegate.sizeHandler = sizeHandler
            }
            
            segue = PresentModallySegue(identifier: nil, source: source, destination: destination)
            
        case .PresentPopup(let sizeHandler):    // popup 창 류
            destination.modalPresentationStyle = .Custom
            destination.transitioningDelegate = transitionDelegate
            if var transitioningDelegate = transitionDelegate as? SizeHandlerHasableTransitionDelgate {
                transitioningDelegate.sizeHandler = sizeHandler
            }
            
            segue = PresentModallySegue(identifier: nil, source: source, destination: destination)
            
        case .PresentAsPopover:
            segue = PresentAsPopoverSegue(identifier: nil, source: source, destination: destination)
            
        case .Embed(let containerView):
            segue = EmbedSegue(identifier: nil, source: source, destination: destination, container: containerView)
        }
        return segue
    }
    
    public func perform() {
        performWithTarget(nil, sender: nil)
    }
    public func performWithSender(sender: AnyObject?) {
        performWithTarget(nil, sender: sender)
    }
    public func performWithTarget(target: UIViewController?, sender: AnyObject? = nil) {
        let destination = self.destination()
        let style = self.style()
        if let segue = getSegue(destination, style: style) {
            // prepareForSegue 호출 (sender 가 있으면 sender 로 없으면 source 로)
            if let target = target {
                target.prepareForSegue(segue, sender: sender)
            } else {
                source.prepareForSegue(segue, sender: sender)
            }
            segue.perform()
        }
    }
}

final class ShowSegue: UIStoryboardSegue, AnimatedSettable {
    var animated: Bool = true
    
    override init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        
    }
    
    override func perform() {
        if let navi = sourceViewController.navigationController {
            navi.pushViewController(destinationViewController, animated: animated)
            // hack for swife back (when backbutton changed), back 버튼이 들어가면 swife 뒤로가기가 안되는 문제가 있어서 그것 해결
            // TODO: - xcode7 다시 확인해야함 - navi.interactivePopGestureRecognizer.delegate = navi as? UIGestureRecognizerDelegate
        }
    }
}

final class ShowDetailSegue: UIStoryboardSegue, AnimatedSettable {
    var animated: Bool = true
    override func perform() {
        if let navi = sourceViewController.navigationController {
            let cnt = navi.viewControllers.count
            var controllers = Array(navi.viewControllers[0..<(cnt-1)])
            controllers.append(destinationViewController)
            navi.setViewControllers(controllers, animated: animated)
        }
    }
}

final class PresentModallySegue: UIStoryboardSegue, AnimatedSettable {
    var animated: Bool = true
    override func perform() {
        sourceViewController.presentViewController(destinationViewController, animated: animated, completion: nil)
    }
}

final class PresentAsPopoverSegue: UIStoryboardSegue, UIPopoverPresentationControllerDelegate {
    override func perform() {
        destinationViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
        destinationViewController.preferredContentSize = CGSizeMake(100, 100)
        if let popoverVC = destinationViewController.popoverPresentationController {
            popoverVC.permittedArrowDirections = UIPopoverArrowDirection()
            popoverVC.delegate = self
            popoverVC.sourceView = sourceViewController.view
            popoverVC.sourceRect = CGRect(x: 100.0, y: 100.0, width: 1, height: 1)
        }
        sourceViewController.presentViewController(destinationViewController, animated: true, completion: nil)
    }
    
    // popoverVC.delegate
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    func popoverPresentationControllerShouldDismissPopover(popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
}

final class EmbedSegue: UIStoryboardSegue {
    
    private weak var containerView: UIView?
    
    init(identifier: String?, source: UIViewController, destination: UIViewController, container: UIView?) {
        super.init(identifier: identifier, source: source, destination: destination)
        containerView = container
    }
    
    override func perform() {
        
        // 기존에 존재하는 child 는 삭제
        containerView?.subviews.forEach({ (v) -> () in
            v.removeFromSuperview()
        })
        sourceViewController.childViewControllers.forEach { (vc) -> () in
            vc.removeFromParentViewController()
        }
        
        sourceViewController.addChildViewController(destinationViewController)
        containerView?.addSubview(destinationViewController.view)
        destinationViewController.didMoveToParentViewController(sourceViewController)
        
        // fill
        let fillConsts = DConstraintsBuilder()
            .addView(destinationViewController.view, name: "parentview")
            .addVFS("V:|[parentview]|")
            .addVFS("H:|[parentview]|")
            .constraints
        containerView?.addConstraints(fillConsts)
    }
}

