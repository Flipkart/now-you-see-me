//
//  ScrollIdleCondition.swift
//  NowYouSeeMe
//
//  Created by Naveen Chaudhary on 22/05/20.
//  Copyright © 2020 Flipkart. All rights reserved.
//

import Foundation

/**
 View condition with minimum percentage that will be satisfied only when the scrollView has stopped scrolling
 
 - Condition will be met when minimum view percentage is satisfied and parent scroll view is idle
 - Condition will fail when minimum percentage condition fails after a previous success
 */
open class ScrollIdleCondition {
    /**
     Percentage of view that needs to be visible to satisfy the condition
     */
    private var minPercentage: Float

    /**
     Maintains whether the condition is satisfied
    */
    private var isMet: Bool = false

    /**
     Stores last known view visible percentage
     */
    private var lastPercentage: Float = -1

    /**
     Initializes ```ScrollIdleCondition``` with provided minimum view percentage
     
     - Parameters:
        - minPercentage: Minimum percentage of the view that needs to be visible to satisfy the condition
            - Ranges from 0 - 100
     */
    public init(minPercentage: Float) {
        self.minPercentage = max(min(minPercentage, 100), 0)
    }

    /**
     Calls conditionMet on main thread
     */
    private func success() {
        DispatchQueue.main.async { [weak self] in
            self?.conditionMet()
        }
    }

    /**
     Calls conditionFailed on main thread
     */
    private func failure() {
        DispatchQueue.main.async { [weak self] in
            self?.conditionFailed()
        }
    }

    /**
     Called when the condition is met (satisfied)

     Subclasses should perform tasks that need to be done after condition is satisfied here
     
     - Important: This method needs to be overridden in subclasses, else it will throw a fatal error
     
     - Note: This method is always called on the main thread
     */
    open func conditionMet() {
        fatalError("Subclasses need to implement the `conditionMet()` method.")
    }

    /**
     Called when the condition fails after previously being met

     Subclasses should perform tasks that need to be done after condition is failed here
     
     - Important: This method needs to be overridden in subclasses, else it will throw a fatal error
     
     - Note: This method is always called on the main thread
    */
    open func conditionFailed() {
        fatalError("Subclasses need to implement the `conditionFailed()` method.")
    }
}

extension ScrollIdleCondition: ViewCondition {
    public func evaluate(for state: ScrollState, viewPercentage: Float) {
        // condition satisfied when scroll is idle and view percentage is greater than minimum percentage
        if !isMet, state == .idle, viewPercentage >= minPercentage {
            // fire success if condition was not perviously satisfied, scroll is idle, and view percentage met
            isMet = true
            // call success
            success()
        } else if isMet, viewPercentage < minPercentage {
            // fire failure if condition was perviously satisfied, and view percentage condition fails
            isMet = false
            // call failure
            failure()
        }
        lastPercentage = viewPercentage
    }

    public func reset() {
        if isMet, lastPercentage < minPercentage {
            // fire failure if condition was perviously satisfied
            isMet = false
            lastPercentage = -1
            // call failure
            failure()
        }
    }
}
