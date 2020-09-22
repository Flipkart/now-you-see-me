//
//  ViewConditions.swift
//  NowYouSeeMe-Demo
//
//  Created by Naveen Chaudhary on 24/05/20.
//  Copyright © 2020 Flipkart. All rights reserved.
//

import UIKit
import NowYouSeeMe

class Viewability: ViewabilityCondition {
    weak var view: UIView?
    
    init(_ view: UIView) {
        super.init(minPercentage: 30, minDuration: 1000)
        
        self.view = view
    }
    
    override func conditionMet() {
        view?.backgroundColor = .yellow
    }
    
    override func conditionFailed() {
        view?.backgroundColor = .magenta
    }
}

class ScrollIdle: ScrollIdleCondition {
    weak var view: UIView?
    
    init(_ view: UIView) {
        super.init(minPercentage: 80)
        
        self.view = view
    }
    
    override func conditionMet() {
        view?.backgroundColor = .cyan
    }
    
    override func conditionFailed() {
        view?.backgroundColor = .brown
    }
}

class Tracking: TrackingCondition {
    weak var view: UIView?
    
    init(_ view: UIView) {
        super.init(minPercentage: 50, minDuration: 1000)
        
        self.view = view
    }
    
    override func conditionMet(startTime: TimeInterval, visibleDuration: Int, maxPercentage: Float) {
        view?.backgroundColor = .orange
    }
    
    override func viewabilityStarted() {
        
    }
    
    override func viewabilityEnded(startTime: TimeInterval, duration: TimeInterval, maxPercentage: Float) {
        
    }
}
