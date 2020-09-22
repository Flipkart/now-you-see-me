//
//  UIViewController+Swizzle.swift
//  NowYouSeeMe
//
//  Created by Naveen Chaudhary on 20/05/20.
//  Copyright © 2020 Flipkart. All rights reserved.
//

import Foundation

/**
 Swizzles methods on UIViewController. lazy var so that it is called only once.
 - present(_:animated:completion:)
 - dismiss(animated:completion:)
 - viewDidAppear(_:)
 - viewWillDisappear(_:)
*/
let swizzleUIViewControllerForTracking: Void = {
    UIViewController.swizzleMethod(originalSelector: #selector(UIViewController.present(_:animated:completion:)), swizzledSelector: #selector(UIViewController.swizzled_present(_:animated:completion:)))

    UIViewController.swizzleMethod(originalSelector: #selector(UIViewController.dismiss(animated:completion:)), swizzledSelector: #selector(UIViewController.swizzled_dismiss(animated:completion:)))

    UIViewController.swizzleMethod(originalSelector: #selector(UIViewController.viewDidAppear(_:)), swizzledSelector: #selector(UIViewController.swizzled_viewDidAppear(_:)))

    UIViewController.swizzleMethod(originalSelector: #selector(UIViewController.viewWillDisappear(_:)), swizzledSelector: #selector(UIViewController.swizzled_viewWillDisappear(_:)))
}()

/**
 Extension on UIViewController for swizzling methods
*/
extension UIViewController {
    /**
     Convenience method to swizzle provided selectors
     - Parameters:
        - originalSelector: The original method
        - swizzledSelector: The new method to replace original method
     */
    fileprivate class func swizzleMethod(originalSelector: Selector, swizzledSelector: Selector) {
        guard let originalMethod = class_getInstanceMethod(Self.self, originalSelector), let swizzledMethod = class_getInstanceMethod(Self.self, swizzledSelector) else {
            return
        }
        // exchange implementations
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }

    /**
     Swizzled implementation of ```present(_:animated:completion:)```
    */
    @objc dynamic fileprivate func swizzled_present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        if let visibleViewController: UIViewController = UIApplication.shared.topMostViewController {
            // notify tracker of top controller that view will hide
            visibleViewController.view.viewTracker?.viewWillHide()
        }

        self.swizzled_present(viewController, animated: true, completion: nil)
    }

    /**
     Swizzled implementation of ```viewDidAppear(_:)```
    */
    @objc dynamic fileprivate func swizzled_dismiss(animated: Bool, completion: (() -> Void)? = nil) {
        self.swizzled_dismiss(animated: animated) {
            completion?()

            if let visibleViewController: UIViewController = UIApplication.shared.topMostViewController {
                // notify tracker of top controller that view is now visible
                visibleViewController.view.viewTracker?.viewDidUnhide()
            }
        }
    }

    /**
     Swizzled implementation of ```viewDidAppear(_:)```
    */
    @objc dynamic fileprivate func swizzled_viewDidAppear(_ animated: Bool) {
        self.swizzled_viewDidAppear(animated)

        // notify tracker that view is now visible
        view.viewTracker?.viewDidUnhide()
    }

    /**
     Swizzled implementation of ```viewWillDisappear(_:)```
    */
    @objc dynamic fileprivate func swizzled_viewWillDisappear(_ animated: Bool) {
        self.swizzled_viewWillDisappear(animated)

        // notify tracker that view is now visible
        view.viewTracker?.viewWillHide()
    }
}
