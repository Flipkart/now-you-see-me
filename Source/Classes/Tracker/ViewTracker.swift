//
//  ViewTracker.swift
//  NowYouSeeMe
//
//  Created by Naveen Chaudhary on 20/05/20.
//  Copyright © 2020 Flipkart. All rights reserved.
//

import Foundation

/**
 Handles viewability of provided UIView
*/
public class ViewTracker: NSObject {
    /**
     The listerner of viewability callbacks
     */
    internal weak var listener: ViewabilityListener?

    /**
     View on which the tracker is attached
     */
    public internal(set) weak var view: UIView?

    /**
     Layer of the view to which tracker is attached.
     - Reference saved to remove observer
     */
    private var viewLayer: CALayer?

    /**
     Maximum visible Percentage of the view
     */
    internal private(set) var maxPercentage: Float = -1

    /**
     Current calculated frame of the view (based on scroll offset)
     */
    internal var absoluteFrame: CGRect = .zero

    /**
     The current visible frame of the view. Calculated by taking intersection of frame with parent's visible frame
    */
    internal private(set) var visibleFrame: CGRect = .zero

    /**
     Last stored visible percentage of the view
     */
    internal private(set) var lastPercentage: Float = -1

    /**
     Additional viewability conditions attached to the view
     */
    internal var conditions: [ViewCondition] = []

    /**
     Reference to the parent view tracker
     */
    internal weak var parent: ViewTracker?

    /**
     Reference to the children view trackers
     */
    internal var children: Set<WeakRef<ViewTracker>> = Set<WeakRef<ViewTracker>>()

    /**
     Determines whether viewability callbacks should be sent to listeners
     
     Used for debug mode, where ```DebugViewTracker``` overrides this
     
     - Note: Default value is true
     */
    internal var shouldNotifyListeners: Bool {
        return true
    }

    /**
     Stores visibility state of the view
     
     - Note: Default value `true`, considering view will be visible when created
     */
    internal var isVisible: Bool = true

    /**
     Initializes the view tracker
     - Parameters:
        - view: the view being tracked
    */
    internal init(_ view: UIView) {
        self.view = view
        super.init()

        // add observers for app state
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)

        // add self in tracking heirarchy
        addNode()

        // add an observer on view's position, bounds
        view.layer.addObserver(self, forKeyPath: "position", options: [.old, .new], context: nil)
        view.layer.addObserver(self, forKeyPath: "bounds", options: [.old, .new], context: nil)

        // store reference to view layer
        viewLayer = view.layer
    }

    deinit {
        // remove self from tracking heirarchy
        removeNode()
        // remove observers
        viewLayer?.removeObserver(self, forKeyPath: "position")
        viewLayer?.removeObserver(self, forKeyPath: "bounds")
    }

    /**
     Resets the stored frame of the view
     - Also, recursively resets the frame of the children
     */
    internal func resetFrame() {
        // reset frame and evaluate
        setAbsoluteFrameAndEvaluate(makeVisible: false)
    }

    /**
     Updates frame with provided change
     - Parameters:
        - delta: The change in frame of the view
     */
    internal func updateFrame(with delta: CGPoint) {
        absoluteFrame = absoluteFrame.offsetBy(dx: delta.x, dy: delta.y)
    }

    /**
     Evaluates viewability of the view and provide callback to listener. Also evaluates additional conditions
     - Parameters:
        - state: The provided scroll state
     */
    internal func evaluateViewability(for state: ScrollState) {
        // calculate visible percentage
        let percentage: Float = visiblePercentage()

        // nothing to do, if no percentage change and scrollview is not idle
        if state != .idle, percentage == lastPercentage {
            return
        }

        maxPercentage = max(maxPercentage, percentage)

        // check if listeners are enabled
        guard shouldNotifyListeners, isVisible else {
            // update last stored view percentage
            lastPercentage = percentage
            return
        }

        if lastPercentage <= 0, percentage > 0 {
            notifyViewStartedToListener()
        } else if lastPercentage > 0, percentage <= 0 {
            notifyViewEndedToListener(maxPercentage: maxPercentage)
        }

        // evaluate additional conditions for current state
        evaluateConditions(for: state, viewPercentage: percentage)

        // update last stored view percentage
        lastPercentage = percentage
    }

    /**
     Calculates visible percentage of the view
     */
    private func visiblePercentage() -> Float {
        // calculate total area
        let totalArea: CGFloat = absoluteFrame.width * absoluteFrame.height
        guard totalArea > 0 else {
            return 0
        }

        // check for parent's frame, if parent is not present, pick absoluteFrame
        let parentVisibleFrame: CGRect = parent?.visibleFrame ?? absoluteFrame

        // calculate visible area by intersection with parent's visible frame
        visibleFrame = parentVisibleFrame.intersection(absoluteFrame)
        let visibleArea: CGFloat = visibleFrame.width * visibleFrame.height

        // calculate visible area percentage
        let percentage: Float = 100.0 * Float(visibleArea / totalArea)
        return percentage
    }

    /**
     Handles view moved out of viewport
     */
    internal func handleViewEnded() {
        // reset last percentage
        lastPercentage = 0

        // check if listeners are enabled
        guard shouldNotifyListeners else {
            return
        }

        // notify listener of view ended
        notifyViewEndedToListener(maxPercentage: maxPercentage)

        // evaluate additional conditions for current state
        evaluateConditions(for: .idle, viewPercentage: 0)
    }

    /**
     Evaluates added conditions for given state on background queue
     - Parameters:
        - state: The current state of the parent scrollView
        - viewPercentage: Current visible percentage of the view
             - Lies between 0-100
             - A value of 0 means view is not visible
             - A value of 100 means view is fully visible
     */
    internal func evaluateConditions(for state: ScrollState, viewPercentage: Float) {
        // evaluate additional conditions for current state
        for condition in conditions {
            condition.evaluate(for: state, viewPercentage: viewPercentage)
        }
    }

    /**
     Removes provided view tracker from the children set
     - Parameters:
        - child: provided child to be removed
     */
    internal func removeChild(_ child: ViewTracker) {
        children = children.filter { $0.value != child && $0.value != nil }
    }

    /**
     Adds provided view tracker to the children set
     - Parameters:
        - child: provided child to be added
     */
    internal func addChild(_ child: ViewTracker) {
        // attach to parent
        children.insert(WeakRef(child))
        child.parent = self

        // update child's frame once added
        child.resetFrame()
    }

    /**
     Marks the tracker and its children as not visible (out of view port)
     */
    internal func markNotVisible() {
        // update visibility
        isVisible = false

        for child in children {
            child.value?.markNotVisible()
        }

        // fire events for view ended
        handleViewEnded()
    }

    /**
     Evaluates viewability for the given scroll state
     
     Also, recursively evaluates all of the children for provided scroll state
     
     - Parameters:
        - state: The provided scroll state
     */
    internal func evaluate(for state: ScrollState) {
        evaluateViewability(for: state)
        for child in children {
            child.value?.evaluate(for: state)
        }
    }

    /**
     Updates frame and then evaluates viewability for the given scroll state
     
     Also, recursively updates frame and evaluates all of the children for provided scroll state
     
     - Parameters:
        - state: The provided scroll state
        - delta: The change in frame of the view
    */
    internal func updateFrameAndEvaluate(for state: ScrollState, with delta: CGPoint) {
        updateFrame(with: delta)
        evaluateViewability(for: state)
        for child in children {
            child.value?.updateFrameAndEvaluate(for: state, with: delta)
        }
    }
}
