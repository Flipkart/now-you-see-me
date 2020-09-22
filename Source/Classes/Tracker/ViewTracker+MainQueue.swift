//
//  ViewTracker+MainQueue.swift
//  NowYouSeeMe
//
//  Created by Naveen Chaudhary on 22/07/20.
//  Copyright © 2020 Flipkart. All rights reserved.
//

import Foundation

// MARK: Listener
extension ViewTracker {
    /**
     Sets listener for viewability events
     - Parameters:
        - listener: The listener to be attached
    */
    internal func setListener(_ listener: ViewabilityListener?) {
        // listener always accessed on main thread
        DispatchQueue.main.async { [weak self] in
            self?.listener = listener
        }
    }

    /**
     Notifies listener on main thread that view has started
     */
    internal func notifyViewStartedToListener() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self, let view = strongSelf.view else {
                return
            }
            strongSelf.listener?.viewStarted(view)
        }
    }

    /**
     Notifies listener on main thread that view has ended
     */
    internal func notifyViewEndedToListener(maxPercentage: Float) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self, let view = strongSelf.view else {
                return
            }
            strongSelf.listener?.viewEnded(view, maxPercentage: maxPercentage)
        }
    }
}

// MARK: UIKit APIs
extension ViewTracker {
    /**
     Finds parent tracker by moving up the responder chain (checks in superviews recursively)
     - Parameters:
        - callback: The block to be called with the parent once found
     */
    internal func findParentViewTracker(_ callback: @escaping (ViewTracker?) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else {
                callback(nil)
                return
            }

            var superview: UIView? = view.superview
            while superview != nil {
                // find parent
                if let parent: ViewTracker = superview?.viewTracker {
                    callback(parent)
                    return
                }
                superview = superview?.superview
            }

            callback(nil)
        }
    }

    /**
     Calculates and resets absolute frame wrt window coordinates
     - Parameters:
        - callback: The block to be called with the boolean indicating whether the frame is set
     */
    internal func resetAbsoluteFrame(_ callback: @escaping (Bool) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self, let view = strongSelf.view else {
                callback(false)
                return
            }

            let newFrame: CGRect = view.convert(view.bounds, to: view.window ?? UIApplication.shared.keyWindow)
            QueueManager.dispatchOnSerialQueue { [weak self] in
                guard let strongSelf = self, strongSelf.isVisible else {
                    return
                }
                strongSelf.absoluteFrame = newFrame
                callback(true)
            }
        }
    }
}
