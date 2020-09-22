//
//  UIView+Swizzle.swift
//  NowYouSeeMe
//
//  Created by Naveen Chaudhary on 20/05/20.
//  Copyright © 2020 Flipkart. All rights reserved.
//

import UIKit

/**
 Swizzles methods on UIView. lazy var so that it is called only once.
 - didMoveToSuperview
 - didMoveToWindow
 */
let swizzleUIViewForTracking: Void = {
    UIView.swizzleMethod(originalSelector: #selector(UIView.didMoveToSuperview), swizzledSelector: #selector(UIView.swizzled_didMoveToSuperview))

    UIView.swizzleMethod(originalSelector: #selector(UIView.didMoveToWindow), swizzledSelector: #selector(UIView.swizzled_didMoveToWindow))
}()

/**
 Extension on UIView for swizzling methods
 */
extension UIView {
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
     Swizzled implementation of ```didMoveToSuperview()```
    */
    @objc dynamic fileprivate func swizzled_didMoveToSuperview() {
        // call original implementation
        self.swizzled_didMoveToSuperview()

        if superview != nil {
            // view is now added to superview, and hence should be added in tracking heirarchy
            viewTracker?.addNode()
        } else {
            // view is now removed from superview, and hence should be removed from tracking heirarchy
            viewTracker?.removeNode()
        }
    }

    /**
     Swizzled implementation of ```didMoveToWindow()```
    */
    @objc dynamic fileprivate func swizzled_didMoveToWindow() {
        // call original implementation
        self.swizzled_didMoveToWindow()

        if window != nil {
            // view is now added to window, and hence should be added in tracking heirarchy
            viewTracker?.addNode()
        }
    }
}
