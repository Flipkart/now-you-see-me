//
//  DebugViewTracker.swift
//  NowYouSeeMe
//
//  Created by Naveen Chaudhary on 01/06/20.
//  Copyright © 2020 Flipkart. All rights reserved.
//

#if DEBUG
import Foundation

/**
 View tracker for DEBUG mode
 - Adds debug functionalities on top of ViewTracker
 */
public class DebugViewTracker: ViewTracker {
    /**
     Boolean indicating whether selective tracking is enabled for this tracker
     */
    private var isSelected: Bool = false

    /**
     Overlay view added for selection
     */
    private var overlayView: UIView?

    override init(_ view: UIView) {
        super.init(view)

        // add notification observer
        NotificationCenter.default.addObserver(self, selector: #selector(displayOverlay), name: DebugNotifications.displayOverlay, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideOverlay), name: DebugNotifications.hideOverlay, object: nil)
    }

    /**
     Displays overlay view
     */
    @objc public func displayOverlay() {
        guard let view = view, overlayView == nil else {
            return
        }

        // create overlay covering entire view
        let overlayView: UIView = UIView(frame: view.bounds)
        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlayView.backgroundColor = .white
        overlayView.layer.borderWidth = 1.0
        overlayView.layer.borderColor = UIColor.black.cgColor
        view.addSubview(overlayView)
        self.overlayView = overlayView

        // left view for discarding view
        let leftView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: overlayView.bounds.width / 2, height: overlayView.bounds.height))
        leftView.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.2)
        leftView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewDiscarded)))
        leftView.autoresizingMask = [.flexibleWidth, .flexibleRightMargin, .flexibleHeight]
        overlayView.addSubview(leftView)

        // right view for selecting view
        let rightView: UIView = UIView(frame: CGRect(x: overlayView.bounds.width / 2, y: 0, width: overlayView.bounds.width / 2, height: overlayView.bounds.height))
        rightView.backgroundColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.2)
        rightView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewSelected)))
        leftView.autoresizingMask = [.flexibleWidth, .flexibleLeftMargin, .flexibleHeight]
        overlayView.addSubview(rightView)

        // label to display view's class name
        let label: UILabel = UILabel(frame: overlayView.bounds)
        label.textAlignment = .center
        label.text = "\(String(describing: type(of: view)))"
        overlayView.addSubview(label)
    }

    /**
     Removes overlay view
     */
    @objc private func hideOverlay() {
        overlayView?.removeFromSuperview()
        overlayView = nil
    }

    /**
     Selects view for tracking
     */
    @objc private func viewSelected() {
        // enable tarcking
        isSelected = true
        // hide overlay
        hideOverlay()
    }

    /**
     Discards view for tracking
     */
    @objc private func viewDiscarded() {
        // disable tracking
        isSelected = false
        // hide overlay
        hideOverlay()
    }

    override var shouldNotifyListeners: Bool {
        return NowYou.watching && (isSelected || !DebugHelper.selectiveTrackingEnabled)
    }

    override func addNode() {
        super.addNode()

        if DebugHelper.selectiveTrackingEnabled, isSelected, let view: UIView = view, let parent: UIView = parent?.view {
            print("NowYouSeeMe: node attached for view: \(view) parent: \(parent)")
        }
    }

    override func removeNode() {
        if DebugHelper.selectiveTrackingEnabled, isSelected, let view: UIView = view, let parent: UIView = parent?.view {
            print("NowYouSeeMe: node detached for view: \(view) parent: \(parent)")
        }

        super.removeNode()
    }

    override func resetFrame() {
        super.resetFrame()

        if DebugHelper.selectiveTrackingEnabled, isSelected, let view: UIView = view {
            print("NowYouSeeMe: frame reset for view: \(view), frame: \(absoluteFrame)")
        }
    }

    override func updateFrame(with delta: CGPoint) {
        super.updateFrame(with: delta)

        if DebugHelper.selectiveTrackingEnabled, isSelected, let view: UIView = view {
            print("NowYouSeeMe: frame update for view: \(view), delta: \(delta), frame: \(absoluteFrame)")
        }
    }

    override func evaluateViewability(for state: ScrollState) {
        let previousPercentage: Float = lastPercentage

        super.evaluateViewability(for: state)

        if DebugHelper.selectiveTrackingEnabled, isSelected, let view: UIView = view, previousPercentage != lastPercentage {
            print("NowYouSeeMe: percentage change for view: \(view), percentage: \(lastPercentage), absolute frame: \(absoluteFrame), visible frame: \(visibleFrame)")
        }
    }

    override func handleViewEnded() {
        super.handleViewEnded()

        if DebugHelper.selectiveTrackingEnabled, isSelected, let view: UIView = view {
            print("NowYouSeeMe: percentage change for view: \(view), percentage: \(lastPercentage), absolute frame: \(absoluteFrame), visible frame: \(visibleFrame)")
        }
    }
}
#endif
