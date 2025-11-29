//  ContentView.swift
//  admob-demo
//
//  Created by Abhishek on 30/11/25.
//
import SwiftUI
import GoogleMobileAds
import Combine

struct AdMobIDs {
    // Use these Google test ad IDs during development
    // Replace with your real IDs before releasing to App Store
    static let isTestMode = true // Set to false for production
    
    static var appOpenAdUnitID: String {
        isTestMode ? "ca-app-pub-3940256099942544/5575463023" : "ca-app-pub-3935114114396535/4783727850"
    }
    
    static var bannerAdUnitID: String {
        isTestMode ? "ca-app-pub-3940256099942544/2435281174" : "ca-app-pub-3935114114396535/2181615249"
    }
    
    static var interstitialAdUnitID: String {
        isTestMode ? "ca-app-pub-3940256099942544/4411468910" : "ca-app-pub-3935114114396535/4495242806"
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

// MARK: - User Progress Model
class UserProgress: ObservableObject {
    @Published var coins: Int = 50
    @Published var completedLessons: Set<Int> = []
    @Published var quizScores: [Int: Int] = [:] // lessonId: score
    @Published var hintsRemaining: Int = 3
    
    func completeLesson(_ lessonId: Int, score: Int) {
        completedLessons.insert(lessonId)
        quizScores[lessonId] = score
    }
    
    func useHint() {
        if hintsRemaining > 0 {
            hintsRemaining -= 1
        }
    }
    
    func earnReward(_ amount: Int) {
        coins += amount
    }
    
    func watchAdForHint() -> Bool {
        hintsRemaining += 1
        return true
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var appOpenAdManager = AppOpenAdManager()
    @StateObject private var interstitialAdManager = InterstitialAdManager()
    @StateObject private var rewardedAdManager = RewardedAdManager()
    @StateObject private var userProgress = UserProgress()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerView
                    
                    // Test Mode Indicator
                    if AdMobIDs.isTestMode {
                        testModeIndicator
                    }
                    
                    // User Stats
                    userStatsView
                    
                    // Lessons Grid
                    lessonsGridView
                    
                    // Bottom Banner Ad
                    BannerAdView(adUnitID: AdMobIDs.bannerAdUnitID)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)
                }
                .padding()
            }
            .navigationTitle("Learn & Earn")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                setupAds()
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    appOpenAdManager.tryToShowAdIfAvailable()
                }
            }
        }
        .environmentObject(userProgress)
        .environmentObject(interstitialAdManager)
        .environmentObject(rewardedAdManager)
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("🎓 AdMob Learning App")
                .font(.title.bold())
            Text("Complete lessons, take quizzes, earn rewards!")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top)
    }
    
    private var testModeIndicator: some View {
        HStack {
            Image(systemName: "flask.fill")
            Text("TEST MODE - Using Google Test Ads")
                .font(.caption)
        }
        .foregroundColor(.orange)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.orange.opacity(0.2))
        .cornerRadius(8)
    }
    
    private var userStatsView: some View {
        HStack(spacing: 20) {
            StatCard(icon: "star.fill", value: "\(userProgress.coins)", label: "Coins", color: .yellow)
            StatCard(icon: "checkmark.circle.fill", value: "\(userProgress.completedLessons.count)", label: "Completed", color: .green)
            StatCard(icon: "lightbulb.fill", value: "\(userProgress.hintsRemaining)", label: "Hints", color: .blue)
        }
        .padding(.vertical)
    }
    
    private var lessonsGridView: some View {
        VStack(spacing: 16) {
            ForEach(1...5, id: \.self) { lessonId in
                NavigationLink(destination: LessonDetailView(lessonId: lessonId)) {
                    LessonCard(
                        lessonId: lessonId,
                        isCompleted: userProgress.completedLessons.contains(lessonId),
                        score: userProgress.quizScores[lessonId]
                    )
                }
            }
        }
    }
    
    private func setupAds() {
        appOpenAdManager.loadAd()
        appOpenAdManager.tryToShowAdIfAvailable()
        interstitialAdManager.loadAd()
        rewardedAdManager.loadAd()
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(value)
                .font(.title3.bold())
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Lesson Card Component
struct LessonCard: View {
    let lessonId: Int
    let isCompleted: Bool
    let score: Int?
    
    var body: some View {
        HStack {
            // Lesson Icon
            ZStack {
                Circle()
                    .fill(isCompleted ? Color.green : Color.blue)
                    .frame(width: 50, height: 50)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .font(.title3.bold())
                } else {
                    Text("\(lessonId)")
                        .foregroundColor(.white)
                        .font(.title3.bold())
                }
            }
            
            // Lesson Info
            VStack(alignment: .leading, spacing: 4) {
                Text("Lesson \(lessonId): SwiftUI Basics")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let score = score {
                    Text("Score: \(score)/100")
                        .font(.subheadline)
                        .foregroundColor(.green)
                } else {
                    Text("Start learning now!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Lesson Detail View
struct LessonDetailView: View {
    let lessonId: Int
    @EnvironmentObject var userProgress: UserProgress
    @EnvironmentObject var interstitialAdManager: InterstitialAdManager
    @State private var showQuiz = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Lesson Content
                Text("Lesson \(lessonId)")
                    .font(.title.bold())
                
                Text("Understanding SwiftUI Components")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                Divider()
                
                // Lesson Body
                VStack(alignment: .leading, spacing: 16) {
                    lessonSection(title: "Introduction", content: "SwiftUI is Apple's modern framework for building user interfaces across all Apple platforms.")
                    
                    lessonSection(title: "Key Concepts", content: "Views are the building blocks of your UI. They describe what should be displayed on screen.")
                    
                    lessonSection(title: "Practice", content: "Try building simple views using Text, Image, and VStack components.")
                }
                
                // Banner Ad in middle of content
                BannerAdView(adUnitID: AdMobIDs.bannerAdUnitID)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                
                // Continue Button
                Button(action: {
                    showQuiz = true
                }) {
                    HStack {
                        Text("Take Quiz")
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.top)
            }
            .padding()
        }
        .navigationTitle("Lesson \(lessonId)")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showQuiz) {
            QuizView(lessonId: lessonId)
        }
    }
    
    private func lessonSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Quiz View
struct QuizView: View {
    let lessonId: Int
    @EnvironmentObject var userProgress: UserProgress
    @EnvironmentObject var interstitialAdManager: InterstitialAdManager
    @EnvironmentObject var rewardedAdManager: RewardedAdManager
    @Environment(\.dismiss) var dismiss
    
    @State private var currentQuestion = 0
    @State private var selectedAnswers: [Int?] = [nil, nil, nil]
    @State private var showResults = false
    @State private var quizScore = 0
    @State private var showHintAlert = false
    @State private var showWatchAdForHint = false
    
    let questions = [
        Question(text: "What is SwiftUI?", options: ["A Framework", "A Language", "An IDE", "A Database"], correctAnswer: 0),
        Question(text: "Which is a basic SwiftUI view?", options: ["UIView", "Text", "UILabel", "View"], correctAnswer: 1),
        Question(text: "What does VStack do?", options: ["Horizontal layout", "Vertical layout", "Grid layout", "No layout"], correctAnswer: 1)
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            if !showResults {
                quizContent
            } else {
                resultsView
            }
        }
        .padding()
        .navigationTitle("Quiz - Lesson \(lessonId)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showWatchAdForHint = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "lightbulb.fill")
                        Text("\(userProgress.hintsRemaining)")
                    }
                }
            }
        }
        .alert("Need a Hint?", isPresented: $showWatchAdForHint) {
            Button("Watch Ad for Hint") {
                if rewardedAdManager.isReady {
                    rewardedAdManager.showAd { amount in
                        _ = userProgress.watchAdForHint()
                        showHintAlert = true
                    }
                }
            }
            Button("Use Hint (\(userProgress.hintsRemaining) left)") {
                if userProgress.hintsRemaining > 0 {
                    userProgress.useHint()
                    showHintAlert = true
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Get help with this question")
        }
        .alert("Hint", isPresented: $showHintAlert) {
            Button("OK") {}
        } message: {
            Text(questions[currentQuestion].hint)
        }
    }
    
    private var quizContent: some View {
        VStack(spacing: 24) {
            // Progress
            HStack {
                Text("Question \(currentQuestion + 1) of \(questions.count)")
                    .font(.headline)
                Spacer()
            }
            
            ProgressView(value: Double(currentQuestion + 1), total: Double(questions.count))
            
            Spacer()
            
            // Question
            Text(questions[currentQuestion].text)
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .padding()
            
            // Options
            VStack(spacing: 12) {
                ForEach(0..<questions[currentQuestion].options.count, id: \.self) { index in
                    Button(action: {
                        selectedAnswers[currentQuestion] = index
                    }) {
                        HStack {
                            Text(questions[currentQuestion].options[index])
                                .foregroundColor(selectedAnswers[currentQuestion] == index ? .white : .primary)
                            Spacer()
                            if selectedAnswers[currentQuestion] == index {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .background(selectedAnswers[currentQuestion] == index ? Color.blue : Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
            }
            
            Spacer()
            
            // Navigation
            HStack {
                if currentQuestion > 0 {
                    Button("Previous") {
                        currentQuestion -= 1
                    }
                    .buttonStyle(.bordered)
                }
                
                Spacer()
                
                Button(currentQuestion < questions.count - 1 ? "Next" : "Finish") {
                    if currentQuestion < questions.count - 1 {
                        currentQuestion += 1
                    } else {
                        finishQuiz()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedAnswers[currentQuestion] == nil)
            }
        }
    }
    
    private var resultsView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Score Display
            VStack(spacing: 16) {
                Text("Quiz Complete!")
                    .font(.title.bold())
                
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                        .frame(width: 150, height: 150)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(quizScore) / 100.0)
                        .stroke(quizScore >= 70 ? Color.green : Color.orange, lineWidth: 20)
                        .frame(width: 150, height: 150)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(quizScore)%")
                        .font(.system(size: 40, weight: .bold))
                }
                
                Text(quizScore >= 70 ? "Great job! 🎉" : "Keep practicing! 💪")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                // Reward
                if quizScore >= 70 {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("+\(quizScore / 10) coins earned!")
                            .font(.headline)
                    }
                    .padding()
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(12)
                }
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 12) {
                Button("Back to Lessons") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                
                if quizScore < 70 {
                    Button("Retry Quiz") {
                        retryQuiz()
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
    }
    
    private func finishQuiz() {
        // Calculate score
        var correct = 0
        for (index, answer) in selectedAnswers.enumerated() {
            if answer == questions[index].correctAnswer {
                correct += 1
            }
        }
        quizScore = (correct * 100) / questions.count
        
        // Save progress
        userProgress.completeLesson(lessonId, score: quizScore)
        
        // Award coins
        if quizScore >= 70 {
            userProgress.earnReward(quizScore / 10)
        }
        
        // Show interstitial ad after quiz completion
        if interstitialAdManager.isReady {
            interstitialAdManager.showAd()
        }
        
        showResults = true
    }
    
    private func retryQuiz() {
        currentQuestion = 0
        selectedAnswers = [nil, nil, nil]
        showResults = false
        quizScore = 0
    }
}

// MARK: - Question Model
struct Question {
    let text: String
    let options: [String]
    let correctAnswer: Int
    
    var hint: String {
        "The correct answer starts with '\(options[correctAnswer].prefix(3))...'"
    }
}

#Preview {
    ContentView()
}
