//
//  UIViewController+Extension.swift
//  makers
//
//  Created by ryan on 2/24/16.
//  Copyright © 2016 kakao. All rights reserved.
//

import UIKit

extension UIViewController {
    
    static weak var topViewController: UIViewController? {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
    
    static func viewControllerFromStoryboard(name storyboardName: String, identifier: String) -> UIViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }
}
