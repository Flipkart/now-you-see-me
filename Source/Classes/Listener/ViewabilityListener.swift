//
//  ViewabilityListener.swift
//  NowYouSeeMe
//
//  Created by Naveen Chaudhary on 20/05/20.
//  Copyright © 2020 Flipkart. All rights reserved.
//

import Foundation

/**
 Listens to viewablity events for a view
 
 Can be attached to an instance of UIView or its subclass by calling ```trackView``` on it
 */
public protocol ViewabilityListener: class {
    /**
     Notifies the listener that the view has entered visible screen
     - Note: This method is always called on the main thread
     - Parameters:
        - view: The instance of view that just entered the viewport
     */
    func viewStarted(_ view: UIView)

    /**
     Notifies the listener that the view has completely moved out of the visible screen
     - Note: This method is always called on the main thread
     - Parameters:
        - view: The instance of view that exited the viewport
     */
    func viewEnded(_ view: UIView, maxPercentage: Float)
}
