// Create a new file to hold AdMob SwiftUI wrappers for Banner, App Open, and support for Interstitial/Rewarded ads.
// This file will:
// - Import GoogleMobileAds
// - Define BannerAdView: a UIViewRepresentable that loads a BannerView with the passed adUnitID
// - Scaffold an AppOpenAdManager class to handle App Open Ad loading/presentation
// - (Stub) Interstitial/Rewarded ad managers for future steps
//
// NOTE: User will need to add 'import GoogleMobileAds' and link the SDK in Xcode for this to compile.

import SwiftUI
import Combine
import GoogleMobileAds
import UIKit

// MARK: - Banner Ad Wrapper
struct BannerAdView: UIViewRepresentable {
    let adUnitID: String

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = adUnitID
        banner.rootViewController = rootViewController()
        banner.delegate = context.coordinator
        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, BannerViewDelegate {
        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            print("✅ Banner ad loaded successfully")
        }
        
        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            print("❌ Banner ad failed to load: \(error.localizedDescription)")
        }
    }
}

// MARK: - Helper to get root view controller
private func rootViewController() -> UIViewController? {
    let scenes = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
    for windowScene in scenes {
        if let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            return rootVC
        }
        if let rootVC = windowScene.windows.first?.rootViewController {
            return rootVC
        }
    }
    return nil
}

// MARK: - App Open Ad Manager
final class AppOpenAdManager: NSObject, ObservableObject, FullScreenContentDelegate {
    private var appOpenAd: AppOpenAd?
    @Published var isShowingAd = false
    @Published var isAdReady = false
    private var loadTime: Date?
    private var isLoadingAd = false
    private var lastAdDismissTime: Date?
    private let minimumInterval: TimeInterval = 4 * 3600 // 4 hours between ads

    func loadAd() {
        guard !isLoadingAd else {
            print("⏳ App Open Ad already loading")
            return
        }
        
        isLoadingAd = true
        isAdReady = false
        print("🔄 Loading App Open Ad...")
        
        let request = Request()
        AppOpenAd.load(
            with: AdMobIDs.appOpenAdUnitID,
            request: request
        ) { [weak self] ad, error in
            guard let self = self else { return }
            
            self.isLoadingAd = false
            
            if let ad = ad {
                self.appOpenAd = ad
                self.loadTime = Date()
                self.isAdReady = true
                ad.fullScreenContentDelegate = self
                print("✅ App Open Ad loaded successfully")
            } else if let error = error {
                print("❌ Failed to load app open ad: \(error.localizedDescription)")
                self.isAdReady = false
            }
        }
    }

    func tryToShowAdIfAvailable() {
        // Check if enough time has passed since last ad
        if let lastDismiss = lastAdDismissTime {
            let timeSinceLastAd = Date().timeIntervalSince(lastDismiss)
            if timeSinceLastAd < minimumInterval {
                print("⏰ Too soon to show another ad (last shown \(Int(timeSinceLastAd))s ago)")
                return
            }
        }
        
        guard !isShowingAd else {
            print("⚠️ App Open Ad already showing")
            return
        }
        
        guard let ad = appOpenAd, isAdReady else {
            print("⚠️ App Open Ad not ready")
            if !isLoadingAd && appOpenAd == nil {
                print("🔄 Loading new App Open Ad")
                loadAd()
            }
            return
        }
        
        // Check if ad is too old (4 hours)
        if let loadTime = loadTime, Date().timeIntervalSince(loadTime) > 4 * 3600 {
            print("⚠️ App Open Ad expired, loading new one")
            appOpenAd = nil
            isAdReady = false
            loadAd()
            return
        }
        
        guard let root = rootViewController() else {
            print("❌ No root view controller available")
            return
        }
        
        print("📺 Presenting App Open Ad")
        isShowingAd = true
        ad.present(from: root)
    }

    // MARK: - FullScreenContentDelegate
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        isShowingAd = false
        isAdReady = false
        appOpenAd = nil
        print("✅ App Open Ad dismissed - Loading next ad")
        loadAd() // Preload next ad
    }
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        isShowingAd = false
        isAdReady = false
        appOpenAd = nil
        print("❌ App open ad failed to present: \(error.localizedDescription)")
        loadAd()
    }
    
    func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
        print("✅ App Open Ad recorded impression")
    }
    
    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("✅ App Open Ad will present")
    }
}

// MARK: - Interstitial Ad Manager
final class InterstitialAdManager: NSObject, ObservableObject, FullScreenContentDelegate {
    private var interstitialAd: InterstitialAd?
    @Published var isLoading = false
    @Published var isReady = false

    func loadAd() {
        guard !isLoading else { return }
        
        isLoading = true
        isReady = false
        
        let request = Request()
        InterstitialAd.load(
            with: AdMobIDs.interstitialAdUnitID,
            request: request
        ) { [weak self] ad, error in
            self?.isLoading = false
            
            if let ad = ad {
                self?.interstitialAd = ad
                self?.isReady = true
                ad.fullScreenContentDelegate = self
                print("Interstitial ad loaded successfully")
            } else if let error = error {
                print("Failed to load interstitial ad: \(error.localizedDescription)")
            }
        }
    }

    func showAd() {
        guard let ad = interstitialAd,
              let root = rootViewController() else {
            print("Interstitial ad not ready")
            return
        }
        
        ad.present(from: root)
    }

    // MARK: - FullScreenContentDelegate
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        interstitialAd = nil
        isReady = false
        loadAd() // Preload next ad
    }
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        interstitialAd = nil
        isReady = false
        print("Interstitial ad failed to present: \(error.localizedDescription)")
        loadAd()
    }
}

// MARK: - Rewarded Ad Manager
final class RewardedAdManager: NSObject, ObservableObject, FullScreenContentDelegate {
    private var rewardedAd: RewardedAd?
    @Published var isLoading = false
    @Published var isReady = false
    var onUserEarnedReward: ((Int) -> Void)?

    func loadAd() {
        guard !isLoading else { return }
        
        isLoading = true
        isReady = false
        
        let request = Request()
        RewardedAd.load(
            with: AdMobIDs.rewardedAdUnitID,
            request: request
        ) { [weak self] ad, error in
            self?.isLoading = false
            
            if let ad = ad {
                self?.rewardedAd = ad
                self?.isReady = true
                ad.fullScreenContentDelegate = self
                print("Rewarded ad loaded successfully")
            } else if let error = error {
                print("Failed to load rewarded ad: \(error.localizedDescription)")
            }
        }
    }

    func showAd(onReward: @escaping (Int) -> Void) {
        guard let ad = rewardedAd,
              let root = rootViewController() else {
            print("Rewarded ad not ready")
            return
        }
        
        onUserEarnedReward = onReward
        ad.present(from: root) { [weak self] in
            let reward = ad.adReward
            let amount = Int(truncating: reward.amount)
            self?.onUserEarnedReward?(amount)
            print("User earned reward: \(amount) \(reward.type)")
        }
    }

    // MARK: - FullScreenContentDelegate
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        rewardedAd = nil
        isReady = false
        onUserEarnedReward = nil
        loadAd() // Preload next ad
    }
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        rewardedAd = nil
        isReady = false
        onUserEarnedReward = nil
        print("Rewarded ad failed to present: \(error.localizedDescription)")
        loadAd()
    }
}
