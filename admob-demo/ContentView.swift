//  ContentView.swift
//  admob-demo
//
//  Created by Abhishek on 30/11/25.
//

import SwiftUI
import GoogleMobileAds

struct AdMobIDs {
    // Use these Google test ad IDs during development
    // Replace with your real IDs before releasing to App Store
    static let isTestMode = true // Set to false for production
    
    static var appOpenAdUnitID: String {
        isTestMode ? "ca-app-pub-3940256099942544/5575463023" : ""
    }
    
    static var bannerAdUnitID: String {
        isTestMode ? "ca-app-pub-3940256099942544/2435281174" : ""
    }
    
    static var interstitialAdUnitID: String {
        isTestMode ? "ca-app-pub-3940256099942544/4411468910" : ""
    }
    
    static var rewardedAdUnitID: String {
        isTestMode ? "ca-app-pub-3940256099942544/1712485313" : ""
    }
    
    static var rewardedInterstitialAdUnitID: String {
        isTestMode ? "ca-app-pub-3940256099942544/6978759866" : ""
    }
    
    static var nativeAdUnitID: String {
        isTestMode ? "ca-app-pub-3940256099942544/3986624511" : ""
    }
}

struct ContentView: View {
    @StateObject private var appOpenAdManager = AppOpenAdManager()
    @StateObject private var interstitialAdManager = InterstitialAdManager()
    @StateObject private var rewardedAdManager = RewardedAdManager()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("AdMob Demo – SwiftUI")
                    .font(.title)
                    .padding(.top)
                
                // Test Mode Indicator
                if AdMobIDs.isTestMode {
                    Text("🧪 TEST MODE - Using Google Test Ads")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(8)
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    NavigationLink("Start Lesson", destination: LessonDetailView())
                    
                    NavigationLink("Start Quiz", destination: QuizView(
                        interstitialAdManager: interstitialAdManager
                    ))
                    
                    NavigationLink("Show Native Ad Screen", destination: NativeAdDemoView())
                    
                    Button("Show Interstitial Demo") {
                        if interstitialAdManager.isReady {
                            interstitialAdManager.showAd()
                        }
                    }
                    .disabled(!interstitialAdManager.isReady)
                    
                    Button("Show Rewarded Demo") {
                        if rewardedAdManager.isReady {
                            rewardedAdManager.showAd { rewardAmount in
                                print("User earned reward: \(rewardAmount)")
                                // Handle reward (e.g., give coins, unlock content)
                            }
                        }
                    }
                    .disabled(!rewardedAdManager.isReady)
                    
                    if interstitialAdManager.isLoading {
                        ProgressView("Loading Interstitial...")
                    }
                    if rewardedAdManager.isLoading {
                        ProgressView("Loading Rewarded...")
                    }
                }
                
                Spacer()
                
                // Banner Ad at bottom
                BannerAdView(adUnitID: AdMobIDs.bannerAdUnitID)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
            }
            .padding()
            .onAppear {
                // Load App Open Ad
                appOpenAdManager.loadAd()
                appOpenAdManager.tryToShowAdIfAvailable()
                
                // Preload other ads
                interstitialAdManager.loadAd()
                rewardedAdManager.loadAd()
            }
            .onChange(of: scenePhase) { newPhase in
                // Show App Open Ad when app becomes active
                if newPhase == .active {
                    appOpenAdManager.tryToShowAdIfAvailable()
                }
            }
        }
    }
}

// MARK: - Placeholder Views

typealias LessonDetailView = DemoPlaceholderView

struct QuizView: View {
    @ObservedObject var interstitialAdManager: InterstitialAdManager
    @State private var quizCompleted = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Quiz View")
                .font(.largeTitle)
            
            Button("Complete Quiz") {
                quizCompleted = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .alert("Quiz Complete!", isPresented: $quizCompleted) {
            Button("OK") {
                // Show interstitial ad after quiz completion
                if interstitialAdManager.isReady {
                    interstitialAdManager.showAd()
                }
            }
        } message: {
            Text("Great job! Here's your result.")
        }
    }
}

struct NativeAdDemoView: View {
    var body: some View {
        DemoPlaceholderView(label: "Native Ad Demo View")
    }
}

struct DemoPlaceholderView: View {
    var label: String = "Lesson Detail View"
    
    var body: some View {
        VStack {
            Spacer()
            Text(label)
                .font(.largeTitle)
            Spacer()
        }
    }
}

#Preview {
    ContentView()
}
