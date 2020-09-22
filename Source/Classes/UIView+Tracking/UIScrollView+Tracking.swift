//
//  UIScrollView+Tracking.swift
//  NowYouSeeMe
//
//  Created by Naveen Chaudhary on 02/06/20.
//  Copyright © 2020 Flipkart. All rights reserved.
//

import Foundation

/**
 Extension on ```UIScrollView``` to add view tracking related methods
*/
extension UIScrollView {
    /**
     Updates value of minimum observable change in scroll offset for view tracking
     
     The default value of throttle is 1.0 which indicates callbacks will be triggered only if there is a change of 1 point in scroll view content offset.
     
     - Note: This method be called only after calling ```trackView()``` on the scroll view
     
     - Parameters:
        - throttle: value to be set for minimum observable change in scroll offset
    */
    public func setThrottle(_ throttle: CGFloat) {
        if let tracker: ScrollTracker = viewTracker as? ScrollTracker {
            tracker.setThrottle(throttle)
        }
    }
}
