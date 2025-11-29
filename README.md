# AdMob Demo - SwiftUI

A complete implementation of Google AdMob integration in SwiftUI, demonstrating all ad formats with proper lifecycle management and best practices.

## 📱 Features

### Ad Formats Implemented
- ✅ **Banner Ads** - Persistent ads at bottom of screens
- ✅ **Interstitial Ads** - Full-screen ads after quiz completion
- ✅ **Rewarded Ads** - Video ads for earning hints
- ✅ **App Open Ads** - Welcome ads on app launch with 4-hour frequency capping

### App Features
- 🎓 Educational learning flow with lessons and quizzes
- 🪙 Coin reward system for quiz completion
- 💡 Hint system with rewarded ad integration
- 📊 Progress tracking (completed lessons, scores, hints)
- 🎨 Clean, modern SwiftUI interface

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 17.0+
- Google Mobile Ads SDK

### Installation

1. Clone the repository
```bash
git clone https://github.com/Abhishek6353/admob-demo.git
cd admob-demo
```

2. Install Google Mobile Ads SDK via Swift Package Manager:
   - In Xcode: File → Add Package Dependencies
   - Enter: `https://github.com/googleads/swift-package-manager-google-mobile-ads.git`

3. Open `admob-demo.xcodeproj` in Xcode

4. Update your AdMob IDs in `ContentView.swift`:
```swift
struct AdMobIDs {
    static let isTestMode = true // Set to false for production
    
    // Replace with your actual ad unit IDs
    static var appOpenAdUnitID: String {
        isTestMode ? "ca-app-pub-3940256099942544/5575463023" : "YOUR-APP-OPEN-ID"
    }
    // ... update other IDs
}
```

5. Update `GADApplicationIdentifier` in `Info.plist` with your AdMob App ID

6. Build and run!

## 📋 Project Structure

```
admob-demo/
├── admob_demoApp.swift          # App entry point with lifecycle management
├── AppDelegate.swift            # AdMob SDK initialization
├── ContentView.swift            # Main view with ad IDs and user progress
├── AdMobViews.swift            # Ad manager classes and SwiftUI wrappers
└── Info.plist                   # AdMob configuration
```

## 🎯 Ad Flow

### App Open Ad
- Shows on app launch (once)
- Shows when returning from background (4-hour cooldown)
- Automatically preloads for next display

### Banner Ad
- Displayed at bottom of home screen
- Displayed in middle of lesson content
- Always visible, non-intrusive

### Interstitial Ad
- Shows after completing a quiz
- Natural transition point
- Auto-reloads after display

### Rewarded Ad
- User-initiated for earning hints
- Clear value exchange
- Rewards user with additional hint

## 🧪 Testing

### Test Mode
Set `isTestMode = true` in `AdMobIDs` to use Google's test ad units:
- Test ads show immediately
- No risk of policy violations
- Perfect for development

### Test Device
Add your device ID in `AppDelegate.swift`:
```swift
GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = 
    ["YOUR-DEVICE-ID"]
```

### Console Logging
Watch Xcode console for ad lifecycle events:
- 🔄 Loading ads
- ✅ Ads loaded successfully
- 📺 Presenting ads
- ❌ Error messages

## 📊 Best Practices Implemented

1. **Frequency Capping** - App Open Ads limited to once per 4 hours
2. **Strategic Placement** - Ads at natural transition points
3. **Preloading** - All ads preload for instant display
4. **Error Handling** - Comprehensive logging and fallback behavior
5. **User Experience** - Non-intrusive, value-added ad placements
6. **State Management** - Proper ad lifecycle with ObservableObject patterns

## 🔧 Configuration

### For Production Release

1. Set test mode to false:
```swift
static let isTestMode = false
```

2. Replace all ad unit IDs with your production IDs

3. Ensure `Info.plist` has correct `GADApplicationIdentifier`

4. Link app to App Store in AdMob console

5. Test thoroughly before submission

### Adjust Frequency Capping

In `AdMobViews.swift`, modify the interval:
```swift
private let minimumInterval: TimeInterval = 4 * 3600 // 4 hours
```

For testing, use shorter intervals like 30 seconds.

## 📱 Requirements

- iOS 17.0+
- Swift 5.9+
- Google Mobile Ads SDK 12.0+

## 🐛 Troubleshooting

### Ads Not Showing?
1. Check `isTestMode = true` for development
2. Verify ad unit IDs are correct
3. Check console for error messages
4. Ensure device has internet connection
5. For real ads, app must be published on App Store

### App Open Ad Not Appearing?
1. Wait 2-3 seconds after launch (loading time)
2. Check 4-hour frequency cap hasn't been reached
3. Look for console messages: "App Open Ad loaded successfully"
4. Try backgrounding and foregrounding the app

### Console Errors?
- "Invalid ad unit ID" → Check your AdMob IDs
- "No fill" → Normal for test environments, use test ad IDs
- "Network error" → Check internet connection

## 📖 Documentation

- [Google Mobile Ads iOS SDK](https://developers.google.com/admob/ios/quick-start)
- [AdMob Best Practices](https://support.google.com/admob/answer/6128543)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

⭐ If this project helped you, please give it a star!

**Note**: Remember to follow [AdMob Program Policies](https://support.google.com/admob/answer/6128543) and never click on your own ads during testing.
