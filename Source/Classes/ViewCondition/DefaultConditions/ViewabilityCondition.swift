//
//  ViewabilityCondition.swift
//  NowYouSeeMe
//
//  Created by Naveen Chaudhary on 22/05/20.
//  Copyright © 2020 Flipkart. All rights reserved.
//

import Foundation

/**
 View condition with minimum percentage and minimum visible duration
 
 - Condition will be met when minimum view percentage is satisfied for minimum specified duration
 - Condition will fail when minimum view percentage condition fails after a previous success
 */
open class ViewabilityCondition {
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
     Stores last known view visible percentage
     */
    private var lastPercentage: Float = -1

    /**
     Maintains whether the viewability condition is satisfied
     */
    private var isMet: Bool = false

    /**
     Maintains whether minimum percentage condition is satisfied
     */
    private var isPercentageMet: Bool = false {
        didSet {
            guard isPercentageMet != oldValue else {
                return
            }

            if isPercentageMet {
                // check for success
                scheduleSuccessTask()
            } else {
                // cancel any scheduled tasks
                successTask?.cancel()
            }
        }
    }

    /**
     Task to be executed when minmum specified view percentage is viewed for minimum specified duration
     */
    private var successTask: DispatchWorkItem?

    /**
     Initializes ```ViewabilityCondition``` with provided minimum view percentage and minimum visible duration
     
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
     Creates and schedule task to check whether condition is successful
     */
    private func scheduleSuccessTask() {
        // create task
        let task: DispatchWorkItem = DispatchWorkItem { [weak self] in
            guard let strongSelf = self, strongSelf.isPercentageMet else {
                return
            }
            // fire success if minimum view condition is still satisfied
            strongSelf.isMet = true
            strongSelf.success()
        }
        // schedule a task to check for success after minimum duration
        QueueManager.serialQueue.asyncAfter(deadline: .now() + .milliseconds(minDuration), execute: task)
        // store reference
        successTask = task
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

extension ViewabilityCondition: ViewCondition {
    public func evaluate(for state: ScrollState, viewPercentage: Float) {
        if !isMet, viewPercentage >= minPercentage {
            // minimum percentage satisfied
            isPercentageMet = true
        } else if viewPercentage < minPercentage {
            // minimum percentage failed
            isPercentageMet = false

            if isMet {
                // fire failure if condition was previously satified
                isMet = false
                // call failure
                failure()
            }
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
        // reset flag
        isPercentageMet = false
    }
}
