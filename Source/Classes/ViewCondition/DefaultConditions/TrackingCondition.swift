//
//  TrackingCondition.swift
//  NowYouSeeMe
//
//  Created by Naveen Chaudhary on 22/05/20.
//  Copyright © 2020 Flipkart. All rights reserved.
//

import Foundation

/**
 View condition with minimum percentage and minimum visible duration that can be used for view analytics
 
 - Success will be called when minimum view percentage condition fails after a previous success and the total duration for which the minimum view percentage condition was satisfied is greater than minimum specified duration
*/
open class TrackingCondition {
    /**
     Percentage of view that needs to be visible to satisfy the condition
     */
    private var minPercentage: Float

    /**
     Duration in milliseconds for which minimum view percentage should be satisfied to satisfy the condition
     - The value is in milliseconds
     */
    private var minDuration: Int

    /**
     The time stamp of when minimum percentage is satisfied
     */
    private var startTime: TimeInterval = -1

    /**
     The max visible view percentage evaluated by the condition
     */
    private var maxPercentage: Float = 0

    /**
     Stores last known view visible percentage
     */
    private var lastPercentage: Float = -1

    /**
     Initializes ```TrackingCondition``` with provided minimum view percentage and minimum visible duration
     
     - Parameters:
        - minPercentage: Minimum percentage of the view that needs to be visible to satisfy the condition
            - Ranges from 0 - 100
        - minDuration: Duration in milliseconds for which minimum view percentage should be satisfied to satisfy the condition
    */
    public init(minPercentage: Float, minDuration: Int) {
        self.minPercentage = max(min(minPercentage, 100), 0)
        self.minDuration = minDuration
    }

    /**
     Evaluates minimum visible duration and fires success if satisfied
     */
    private func evaluateDuration(startTime: TimeInterval) {
        guard startTime > 0 else {
            return
        }

        // calculate visible duration
        let endTime: TimeInterval = NSDate().timeIntervalSince1970
        let durationInMs: Int = Int(endTime - startTime) * 1000
        let viewMaxPercentage: Float = maxPercentage

        if durationInMs >= minDuration {
            // fire success if condition met
            // call success on main thread
            DispatchQueue.main.async { [weak self] in
                self?.conditionMet(startTime: startTime, visibleDuration: durationInMs, maxPercentage: viewMaxPercentage)
            }
        }
    }

    /**
     Called when the condition is met (satisfied)
     
     Subclasses should perform tasks that need to be done after condition is satisfied here
     
     - Parameters:
        - startTime: The timestamp when minimum percentage condition was first satisfied
        - visibleDuration: The total duration for which minimum percentage condition was satisfied
        - maxPercentage: The maximum visible percentage of the view in the visible duration
     
     - Important: This method needs to be overridden in subclasses, else it will throw a fatal error
     
     - Note: This method is always called on the main thread
    */
    open func conditionMet(startTime: TimeInterval, visibleDuration: Int, maxPercentage: Float) {
        fatalError("Subclasses need to implement the `conditionMet(visibleDuration:maxPercentage:)` method.")
    }

    /**
     Called when the minimum percentage condition is first satisfied

     Subclasses should perform tasks that need to be done once viewability starts here

     - Important: This method needs to be overridden in subclasses, else it will throw a fatal error
     
     - Note: This method is always called on the main thread
    */
    open func viewabilityStarted() {
        fatalError("Subclasses need to implement the `viewabilityStarted()` method.")
    }

    /**
     Called when the minimum percentage condition fails after a previous success
     
     Subclasses should perform tasks that need to be done once viewability ends here

     - Important: This method needs to be overridden in subclasses, else it will throw a fatal error
     
     - Note: This method is always called on the main thread
    */
    open func viewabilityEnded(startTime: TimeInterval, duration: TimeInterval, maxPercentage: Float) {
        fatalError("Subclasses need to implement the `viewabilityEnded()` method.")
    }
}

extension TrackingCondition: ViewCondition {
    public func evaluate(for state: ScrollState, viewPercentage: Float) {
        // update max view percentage
        maxPercentage = max(maxPercentage, viewPercentage)

        if viewPercentage >= minPercentage, startTime <= 0 {
            // update start time when minimum view percentage is satisfied
            startTime = NSDate().timeIntervalSince1970

            DispatchQueue.main.async { [weak self] in
                self?.viewabilityStarted()
            }
        } else if viewPercentage < minPercentage, startTime > 0 {
            // calculate visible duration
            let viewStartTime: TimeInterval = startTime
            let viewMaxPercentage: Float = maxPercentage
            let endTime: TimeInterval = NSDate().timeIntervalSince1970
            let durationInMs: TimeInterval = (endTime - viewStartTime) * 1000
            // evaluate total visible duration when minimum view percentage fails
            evaluateDuration(startTime: viewStartTime)
            DispatchQueue.main.async { [weak self] in
                self?.viewabilityEnded(startTime: viewStartTime, duration: durationInMs, maxPercentage: viewMaxPercentage)
            }
            // reset start time
            startTime = -1
        }
        lastPercentage = viewPercentage
    }

    public func reset() {
        if lastPercentage < minPercentage {
            // evaluate condition if valid start time
            evaluateDuration(startTime: startTime)
            // reset start time
            startTime = -1
            // reset max percentage
            maxPercentage = 0
        }
    }
}
