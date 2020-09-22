//
//  ViewTracker+BackgroundQueue.swift
//  NowYouSeeMe
//
//  Created by Naveen Chaudhary on 22/07/20.
//  Copyright © 2020 Flipkart. All rights reserved.
//

import Foundation

// MARK: Entry Points
extension ViewTracker {
    /**
     Sets viewability conditions to the tracker on background queue
     - Parameters:
        - conditions: The viewability conditions to be attached
     */
    internal func setConditions(_ conditions: [ViewCondition]) {
        QueueManager.dispatchOnSerialQueue { [weak self] in
            guard let strongSelf = self else {
                return
            }

            // reset old conditions
            for condition in strongSelf.conditions {
                condition.reset()
            }
            // set new conditions
            strongSelf.conditions = conditions
        }
    }

    /**
     Finds and attaches the tracker to its parent tracker
     */
    @objc internal func addNode() {
        QueueManager.dispatchOnSerialQueue { [weak self] in
            guard let strongSelf = self, strongSelf.parent == nil else {
                return
            }

            strongSelf.findParentViewTracker { parent in
                QueueManager.dispatchOnSerialQueue {
                    parent?.addChild(strongSelf)
                }
            }
        }
    }

    /**
     Removes the tracker from parent
     */
    @objc internal func removeNode() {
        if QueueManager.isSerialQueue {
            // remove tracker
            parent?.removeChild(self)
            parent = nil
        } else {
            // sync needed as this is also called from deinit
            QueueManager.serialQueue.sync {
                // remove tracker
                parent?.removeChild(self)
                parent = nil
            }
        }
    }

    /**
     Handles viewability when app resigns active
     */
    @objc internal func appWillResignActive() {
        QueueManager.dispatchOnSerialQueue { [weak self] in
            self?.handleViewEnded()
        }
    }

    /**
     Handles viewability when app becomes active
     */
    @objc internal func appDidBecomeActive() {
        QueueManager.dispatchOnSerialQueue { [weak self] in
            self?.evaluateViewability(for: .idle)
        }
    }

    /**
     Updates frame and evaluates viewability of self and children
     */
    internal func viewDidUnhide() {
        // reset frame and evaluate
        QueueManager.dispatchOnSerialQueue { [weak self] in
            self?.setAbsoluteFrameAndEvaluate(makeVisible: true)
        }
    }

    /**
     Ends viewability of self and children
     */
    internal func viewWillHide() {
        QueueManager.dispatchOnSerialQueue { [weak self] in
            self?.markNotVisible()
        }
    }

    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let layer = object as? CALayer, layer == self.view?.layer, (keyPath == "position" || keyPath == "bounds") else {
            return
        }

        if keyPath == "position", let oldValue: CGPoint = change?[.oldKey] as? CGPoint, let newValue: CGPoint = change?[.newKey] as? CGPoint, oldValue == newValue {
            // return if position has not changed
            return
        }

        if keyPath == "bounds", let oldValue: CGRect = change?[.oldKey] as? CGRect, let newValue: CGRect = change?[.newKey] as? CGRect, oldValue.size == newValue.size {
            // return if bounds size has not changed
            return
        }

        // reset frame if there is a change in layer's position or bounds
        QueueManager.dispatchOnSerialQueue { [weak self] in
            self?.resetFrame()
        }
    }
}

// MARK: Reset frame
extension ViewTracker {
    /**
     Resets the stored absolute frame of the view and evaulates viewability
     
     Also, recursively resets the frame of the children
     
     - Parameters:
        - makeVisible: Boolean inidicating whether to mark the view as visible
    */
    internal func setAbsoluteFrameAndEvaluate(makeVisible: Bool) {
        // update visibility if needed
        isVisible = isVisible || makeVisible

        guard isVisible else {
            return
        }

        // reset absolute frame
        resetAbsoluteFrame { [weak self] success in
            guard success else {
                return
            }

            QueueManager.dispatchOnSerialQueue { [weak self] in
                guard let strongSelf = self, strongSelf.isVisible else {
                    return
                }

                // evaluate viewability after resetting absolute frame
                strongSelf.evaluateViewability(for: .idle)

                // update children frame
                for child in strongSelf.children {
                    child.value?.setAbsoluteFrameAndEvaluate(makeVisible: makeVisible)
                }
            }
        }
    }
}
