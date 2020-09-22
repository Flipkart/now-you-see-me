//
//  QueueManager.swift
//  NowYouSeeMe
//
//  Created by Shashwat KN on 22/05/20.
//  Copyright © 2020 Flipkart. All rights reserved.
//

import Foundation

/**
 Manages background queues
 */
internal class QueueManager: NSObject {
    /**
     Specific key added on the serial queue
     */
    static private let serialQueueSpecificKey: DispatchSpecificKey<String> = DispatchSpecificKey<String>()

    /**
     Specific value set against serialQueueSpecificKey on serial queue
     */
    static private let serialQueueSpecificValue: String = "NowYouSeeMe.viewabilityQueue"

    /**
     Checks whether current queue is QueueManager.serialQueue
     */
    static internal var isSerialQueue: Bool {
        return DispatchQueue.getSpecific(key: QueueManager.serialQueueSpecificKey) == QueueManager.serialQueueSpecificValue
    }

    /**
     Serial background queue for managing viewability calculations
     */
    static internal let serialQueue: DispatchQueue = {
        let queue: DispatchQueue = DispatchQueue(label: "NowYouSeeMe.viewabilityQueue")
        queue.setSpecific(key: serialQueueSpecificKey, value: serialQueueSpecificValue)
        return queue
    }()

    /**
     Use this to perform any task on serial queue.
     
     If already on serial queue, block will be executed immediately, else scheduled for async dispatch on serial queue.
     */
    static internal func dispatchOnSerialQueue(_ work: @escaping () -> Void) {
        if isSerialQueue {
            work()
        } else {
            serialQueue.async {
                work()
            }
        }
    }
}
