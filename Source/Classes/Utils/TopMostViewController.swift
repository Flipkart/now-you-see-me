//
//  VCUtils.swift
//  NowYouSeeMe
//
//  Created by Naveen Chaudhary on 21/05/20.
//  Copyright © 2020 Flipkart. All rights reserved.
//

import Foundation

extension UIApplication {
    /**
     The top global visible view controller
     */
    internal var topMostViewController: UIViewController? {
        return self.keyWindow?.rootViewController?.topMostViewController
    }
}

extension UIViewController {
    /**
     The top visible starting from current controller
    */
    fileprivate var topMostViewController: UIViewController {
        if let presentedController: UIViewController = self.presentedViewController {
            // if a view controller is presented, find the top view controller from presented controller
            return presentedController.topMostViewController
        }

        if let navigationController: UINavigationController = self as? UINavigationController {
            // find the top view controller from the visible controller of navigation controller
            return navigationController.visibleViewController?.topMostViewController ?? navigationController
        }

        if let tab: UITabBarController = self as? UITabBarController {
            // find the top view controller from the selected controller of tab controller
            return tab.selectedViewController?.topMostViewController ?? tab
        }

        // return self
        return self
    }
}
