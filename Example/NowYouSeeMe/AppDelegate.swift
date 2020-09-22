//
//  AppDelegate.swift
//  NowYouSeeMe-Demo
//
//  Created by Naveen Chaudhary on 19/05/20.
//  Copyright © 2020 Flipkart. All rights reserved.
//

import UIKit
import NowYouSeeMe
import GDPerformanceView_Swift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // enable tracking
        NowYou.seeMe()
        
        // start performance monitoring
        PerformanceMonitor.shared().start()
        return true
    }

}

