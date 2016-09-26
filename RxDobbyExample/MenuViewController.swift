//
//  MenuViewController.swift
//  RxDobby
//
//  Created by ryan on 9/8/16.
//  Copyright © 2016 kimyoungjin. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        view.addGestureRecognizer(
            UIPanGestureRecognizer(target: self, action: #selector(MenuViewController.viewPannedLeft(_:))))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    weak var centerViewController: UIViewController?
    var oldXPostion: CGFloat = 0.0
    
    func viewPannedRight(_ recognizer: UIPanGestureRecognizer) {
        
        guard let centerViewController = centerViewController else {
            return
        }
        
        let leftToRight = (recognizer.velocity(in: view).x > 0)
        switch recognizer.state {
        case .began:
            oldXPostion = view.frame.origin.x
        case .changed:
            let deltaX = recognizer.translation(in: view).x
            recognizer.setTranslation(CGPoint.zero, in: view)
            
            if view.frame.origin.x + deltaX > centerViewController.view.frame.width {
                break
            }
            
            if view.frame.origin.x + view.frame.width + deltaX < centerViewController.view.frame.width {
                break
            }
            
            view.frame.origin.x = view.frame.origin.x + deltaX
        case .ended:
            if leftToRight {
                dismiss(animated: true, completion: nil)
            } else {
                // 처음 위치로 되돌아감
                UIView.animate(withDuration: 0.5,
                                           delay: 0,
                                           usingSpringWithDamping: 1.0,
                                           initialSpringVelocity: 0,
                                           options: UIViewAnimationOptions(),
                                           animations: {
                                            self.view.frame.origin.x = self.oldXPostion
                    },
                                           completion: nil)
                
            }
        default:
            break
        }
    }

    
    func viewPannedLeft(_ recognizer: UIPanGestureRecognizer) {
        
        let rightToLeft = (recognizer.velocity(in: view).x < 0)
        switch recognizer.state {
        case .began:
            oldXPostion = view.frame.origin.x
        case .changed:
            let deltaX = recognizer.translation(in: view).x
            recognizer.setTranslation(CGPoint.zero, in: view)
            
            if 0 < view.frame.origin.x + deltaX {
                break
            }
            
            if view.frame.origin.x + view.frame.width + deltaX < 0 {
                break
            }
            
            view.frame.origin.x = view.frame.origin.x + deltaX
        case .ended:
            if rightToLeft {
                dismiss(animated: true, completion: nil)
            } else {
                // 처음 위치로 되돌아감
                UIView.animate(withDuration: 0.5,
                               delay: 0,
                               usingSpringWithDamping: 1.0,
                               initialSpringVelocity: 0,
                               options: UIViewAnimationOptions(),
                               animations: {
                                self.view.frame.origin.x = self.oldXPostion
                    },
                               completion: nil)
                
            }
        default:
            break
        }
    }

}
