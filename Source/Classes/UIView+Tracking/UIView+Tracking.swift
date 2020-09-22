//
//  UIView+ViewTracker.swift
//  NowYouSeeMe
//
//  Created by Shashwat KN on 18/05/20.
//  Copyright © 2020 Flipkart. All rights reserved.
//

import UIKit

/**
 Keys for storing associated objects
 */
internal struct AssociatedKeys {
    static var viewTracker: UInt8 = 0
}

/**
 Extension on ```UIView``` to add view tracking related methods
 */
extension UIView {
    /**
     Starts view tracking on the view instance
     
     This method needs to be called to track the viewability of any particular view instance.
          
     - Important: This method also needs to be called on the parent UIViewController's view
     - Important: This method also needs to be called on any parent UIScrollView instance
     - Important: This method also needs to be called on any parent recyclable view like UITableViewCell or UICollectionViewCell
     
     - Parameters:
        - listener: The listener for change in viewability state of the view
        - conditions: Additional viewability conditions attached to the view
     */
    public func trackView(_ listener: ViewabilityListener? = nil, conditions: [ViewCondition] = []) {
        // do not track if not enabled
        guard NowYou.watching else {
            return
        }

        if let viewTracker: ViewTracker = viewTracker {
            // update conditions and listener if tracker already present
            viewTracker.setConditions(conditions)
            viewTracker.setListener(listener)
            return
        }

        // setup the tracker
        let tracker: ViewTracker
        if let scrollView: UIScrollView = self as? UIScrollView {
            // special handling for scrollviews
            #if DEBUG
            tracker = DebugScrollTracker(scrollView)
            #else
            tracker = ScrollTracker(scrollView)
            #endif
        } else {
            #if DEBUG
            tracker = DebugViewTracker(self)
            #else
            tracker = ViewTracker(self)
            #endif
        }
        tracker.setConditions(conditions)
        tracker.setListener(listener)

        // add tracker to view's associated objects
        objc_setAssociatedObject(self, &AssociatedKeys.viewTracker, tracker, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    /**
     Returns the stored tracker object, or nil if not stored
     */
    internal var viewTracker: ViewTracker? {
        guard let tracker = objc_getAssociatedObject(self, &AssociatedKeys.viewTracker) as? ViewTracker else {
            return nil
        }
        return tracker
    }
}
