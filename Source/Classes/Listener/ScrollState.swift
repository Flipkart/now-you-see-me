//
//  ScrollState.swift
//  NowYouSeeMe
//
//  Created by Naveen Chaudhary on 20/05/20.
//  Copyright © 2020 Flipkart. All rights reserved.
//

import Foundation

/**
 The different possible states of any scrollable view
 */
public enum ScrollState: Equatable {
    /**
     The scrollable view is in a state of rest and not scrolling
     */
    case idle

    /**
     The scrollable view is scrolling
     
     - delta: The change in contentOffset from the last state.
       - negative x -> scrolling right
       - positive x -> scrolling left
       - negative y -> scrolling down
       - positive y -> scrolling up
     */
    case scrolling(delta: CGPoint)
}
