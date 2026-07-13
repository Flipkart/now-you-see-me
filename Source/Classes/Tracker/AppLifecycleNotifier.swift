//
//  AppLifecycleNotifier.swift
//  NowYouSeeMe
//
//  Copyright © 2020 Flipkart. All rights reserved.
//

import UIKit

/// Registers one pair of app lifecycle observers and fans out to active view trackers.
internal final class AppLifecycleNotifier: NSObject {
    static let shared = AppLifecycleNotifier()

    private var trackers: Set<WeakRef<ViewTracker>> = []

    private override init() {
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    func register(_ tracker: ViewTracker) {
        QueueManager.dispatchOnSerialQueue { [weak self] in
            self?.trackers.insert(WeakRef(tracker))
            self?.prune()
        }
    }

    func unregister(_ tracker: ViewTracker) {
        if QueueManager.isSerialQueue {
            trackers = trackers.filter { $0.value != tracker && $0.value != nil }
        } else {
            QueueManager.serialQueue.sync {
                trackers = trackers.filter { $0.value != tracker && $0.value != nil }
            }
        }
    }

    private func prune() {
        trackers = trackers.filter { $0.value != nil }
    }

    @objc private func appWillResignActive() {
        QueueManager.dispatchOnSerialQueue { [weak self] in
            self?.prune()
            self?.trackers.forEach { $0.value?.appWillResignActive() }
        }
    }

    @objc private func appDidBecomeActive() {
        QueueManager.dispatchOnSerialQueue { [weak self] in
            self?.prune()
            self?.trackers.forEach { $0.value?.appDidBecomeActive() }
        }
    }
}
