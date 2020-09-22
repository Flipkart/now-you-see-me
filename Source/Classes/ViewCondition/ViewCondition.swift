//
//  Condition.swift
//  NowYouSeeMe
//
//  Created by Shashwat KN on 18/05/20.
//  Copyright © 2020 Flipkart. All rights reserved.
//

import Foundation

/**
 A tracking condition attached to a view instance
 
 Can be attached to an instance of UIView or its subclass by calling ```trackView``` on it
 */
public protocol ViewCondition {
    /**
     Notifies the condition to evaluate its state based on current visible percentage of the view and the current scroll state

     - Parameters:
        - state: The current scroll state of the parent scrollable view
        - viewPercentage: Current visible percentage of the view
            - Lies between 0-100
            - A value of 0 means view is not visible
            - A value of 100 means view is fully visible
     
     - Note: This method is always called on the background thread
     */
    func evaluate(for state: ScrollState, viewPercentage: Float)

    /**
     Notifies the condition to reset to the default state.
     
     This is called when the conditions attached to a view are modified or set again (in case of recycling of views)
     
     - Note: This method is always called on the background thread
     */
    func reset()
}
