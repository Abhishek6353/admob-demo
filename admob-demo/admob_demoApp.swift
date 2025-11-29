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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appOpenAdManager = AppOpenAdManager()
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var hasShownInitialAd = false
    
    init() {
        print("🚀 App Initializing...")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appOpenAdManager)
                .onAppear {
                    // Load and show app open ad on first launch only
                    if !hasShownInitialAd {
                        print("👀 ContentView appeared - Loading App Open Ad")
                        appOpenAdManager.loadAd()
                        
                        // Wait for ad to load, then show it
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            appOpenAdManager.tryToShowAdIfAvailable()
                            hasShownInitialAd = true
                        }
                    }
                }
                .onChange(of: scenePhase) { oldPhase, newPhase in
                    handleScenePhaseChange(oldPhase: oldPhase, newPhase: newPhase)
                }
        }
    }
    
    private func handleScenePhaseChange(oldPhase: ScenePhase, newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            print("✅ App became active")
            // Only try to show if we're returning from background (not initial launch)
            if oldPhase == .background && hasShownInitialAd {
                print("🔄 Returning from background - attempting to show App Open Ad")
                appOpenAdManager.tryToShowAdIfAvailable()
            }
            
        case .background:
            print("📱 App went to background")
            
        case .inactive:
            print("⏸️ App became inactive")
            
        @unknown default:
            break
        }
    }
}
