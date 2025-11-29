//
//  AppDelegate.swift
//  admob-demo
//
//  Created by Abhishek on 30/11/25.
//

import UIKit
import GoogleMobileAds

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Initialize Google Mobile Ads SDK
        MobileAds.shared.start(completionHandler: nil)
        
        // Configure test devices
        MobileAds.shared.requestConfiguration.testDeviceIdentifiers = ["dfbc254c8885ce59262eebf55e5e7595"]
        
        print("✅ AdMob SDK Initialized")
        print("📱 Version: \(MobileAds.shared.versionNumber)")
        
        return true
    }
}
