//
//  admob_demoApp.swift
//  admob-demo
//
//  Created by Abhishek on 30/11/25.
//

import SwiftUI
import GoogleMobileAds

@main
struct admob_demoApp: App {
    init() {
        MobileAds.shared.requestConfiguration.testDeviceIdentifiers = [ "dfbc254c8885ce59262eebf55e5e7595" ]
        // Initialize Google Mobile Ads SDK
        MobileAds.shared.start(completionHandler: nil)
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
