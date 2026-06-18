//
//  ScrollTracker.swift
//  NowYouSeeMe
//
//  Created by Naveen Chaudhary on 20/05/20.
//  Copyright © 2020 Flipkart. All rights reserved.
//

import Foundation

/**
 Handles scroll states for scroll view
 */
internal class ScrollTracker: ViewTracker {
    /**
     Reference to the scroll view managed by the tarcker
     */
    private weak var scrollView: UIScrollView?

    /**
     Task to be executed when scroll stops (idle scroll view)
     */
    private var scrollIdleTask: DispatchWorkItem?

    /**
     Last stored contentOffset of the scroll view
     */
    private var lastScrollOffset: CGPoint {
        didSet {
            if lastScrollOffset != oldValue {
                // check for scrollIdle
                scheduleScrollIdleTask()
            }
        }
    }

    /**
     Minimum observable change in scroll offset
     - Default value of throttle is 1.0
     */
    private var throttle: CGFloat = 1.0

    /**
     Initializes the scroll tracker
     - Parameters:
        - scrollView: the scrollView being tracked
     */
    internal init(_ scrollView: UIScrollView) {
        self.scrollView = scrollView
        self.lastScrollOffset = scrollView.contentOffset

        super.init(scrollView)

        // add observer on scrollView's contentOffset
        scrollView.addObserver(self, forKeyPath: "contentOffset", options: [.new], context: nil)
    }

    deinit {
        // remove observer
        scrollView?.removeObserver(self, forKeyPath: "contentOffset")
    }

    /**
     Creates and schedule task to check whether scroll view is idle
     */
    private func scheduleScrollIdleTask() {
        // cancel any previous scheduled call
        scrollIdleTask?.cancel()

        let task: DispatchWorkItem = DispatchWorkItem { [weak self] in
            guard let strongSelf = self else {
                return
            }

            // scroll has stopped, update state
            strongSelf.updateChildren(for: .idle)
        }
        // schedule task to check for scroll idle after 300 ms
        QueueManager.serialQueue.asyncAfter(deadline: .now() + .milliseconds(300), execute: task)

        self.scrollIdleTask = task
    }

    /**
     Handles change in contentOffset of scrollView
     - Parameters:
        - contentOffset: The current content offset of the scroll view
    */
    private func handleScrollUpdate(with contentOffset: CGPoint) {
        // return if not visible
        guard isVisible else {
            return
        }

        let delta: CGPoint = calculateDelta(with: contentOffset)

        // handle data if delta (change in offset) is greater than throttle value
        if abs(delta.x) >= throttle || abs(delta.y) >= throttle {
            // update children for a change in scroll state
            updateChildren(for: .scrolling(delta: delta))
            // update last stored content offset
            lastScrollOffset = contentOffset
        }
    }

    /**
     Calculates the change in content offset of scroll view
     - Parameters:
        - contentOffset: The current content offset of the scroll view
     - Returns: CGPoint indicating a change in x and y content offset of the scroll view
         - negative x -> scrolling right
         - positive x -> scrolling left
         - negative y -> scrolling down
         - positive y -> scrolling up
     */
    private func calculateDelta(with contentOffset: CGPoint) -> CGPoint {
        return CGPoint(x: lastScrollOffset.x - contentOffset.x, y: lastScrollOffset.y - contentOffset.y)
    }

    /**
     Updates all the children of the tracker for the provided scroll state
     - Parameters:
        - state: The provided scroll state
     */
    internal func updateChildren(for state: ScrollState) {
        for child in children {
            switch state {
            case .idle:
                child.value?.evaluate(for: state)
            case .scrolling(let delta):
                child.value?.updateFrameAndEvaluate(for: state, with: delta)
            }
        }
    }
}

// MARK: Serial Queue
extension ScrollTracker {
    /**
     Updates value of minimum observable change in scroll offset
     - Parameters:
        - throttle: value to be set for minimum observable change in scroll offset
     */
    internal func setThrottle(_ throttle: CGFloat) {
        QueueManager.dispatchOnSerialQueue { [weak self] in
            self?.throttle = throttle
        }
    }

    override internal func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let scrollView = object as? UIScrollView, scrollView == self.scrollView, keyPath == "contentOffset" else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }

        let contentOffset: CGPoint = scrollView.contentOffset

        QueueManager.dispatchOnSerialQueue { [weak self] in
            self?.handleScrollUpdate(with: contentOffset)
        }
    }
}
